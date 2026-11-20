# frozen_string_literal: true

class ConvertPrimaryKeysAndReferencesToUuid < ActiveRecord::Migration[8.1]
  EXCLUDED_TABLES = %w[
    schema_migrations
    ar_internal_metadata
  ].freeze

  EXCLUDED_TABLE_PREFIXES = %w[
    solid_queue_
    solid_cache_
    solid_cable_
  ].freeze

  TIMESTAMP_CANDIDATES = %w[created_at].freeze

  # References that have no database foreign key constraint. Historical orphans are kept
  # as deterministic UUIDs so rows are never lost or silently re-pointed.
  UNCONSTRAINED_FOREIGN_KEYS = [
    { source_table: "identifiers", source_column: "magician_id", target_table: "magicians" },
    { source_table: "identifiers", source_column: "muggle_id", target_table: "muggles" },
    { source_table: "listed_items", source_column: "list_id", target_table: "lists" },
    { source_table: "listed_items", source_column: "replacing", target_table: "listed_items" },
    { source_table: "lists", source_column: "magician_id", target_table: "magicians" },
    { source_table: "muggles", source_column: "magician_id", target_table: "magicians" },
    { source_table: "muggles", source_column: "purchase_id", target_table: "purchases" },
    { source_table: "purchases", source_column: "magician_id", target_table: "magicians" }
  ].freeze

  POLYMORPHIC_TABLE_OVERRIDES = {
    "ActiveStorage::Blob" => "active_storage_blobs",
    "ActiveStorage::Attachment" => "active_storage_attachments",
    "ActiveStorage::VariantRecord" => "active_storage_variant_records"
  }.freeze

  def up
    target_pk_map = discover_target_tables
    return if target_pk_map.empty?

    target_tables = target_pk_map.keys
    target_set = target_tables.to_set

    foreign_keys = discover_foreign_keys(target_set)
    unconstrained_fks = discover_unconstrained_foreign_keys(target_set)
    polymorphic_refs = discover_polymorphic_references(foreign_keys, unconstrained_fks)

    converted_columns = build_converted_columns_map(target_tables, foreign_keys, unconstrained_fks, polymorphic_refs)
    affected_tables = converted_columns.keys.sort

    dependent_constraints = discover_dependent_constraints(affected_tables, converted_columns)
    dependent_indexes = discover_dependent_indexes(affected_tables, converted_columns)

    create_uuid_helper_functions!

    # 1. Backfill deterministic, chronologically ordered RFC 9562 UUIDv7 primary keys.
    target_tables.each do |table|
      backfill_primary_key_uuids!(table)
    end

    # 2. Backfill constrained foreign keys.
    unique_fk_columns(foreign_keys).each do |fk|
      backfill_foreign_key_uuids!(fk, allow_orphans: false)
    end

    # 3. Backfill unconstrained foreign-key columns (preserving historical orphans deterministically).
    unconstrained_fks.each do |fk|
      backfill_foreign_key_uuids!(fk, allow_orphans: true)
    end

    # 4. Backfill polymorphic *_id references (blank-type rows with a non-null id receive a deterministic orphan UUID; NULL ids stay NULL).
    polymorphic_refs.each do |ref|
      backfill_polymorphic_uuids!(ref, target_set)
    end

    # Log old integer -> new UUID mapping for books before dropping books.id so DEFAULT_BOOK_IDS can be updated from deploy logs.
    log_migrated_books! if target_set.include?("books")

    # 5. Drop dependent FKs, check/unique constraints, and indexes before swapping columns.
    foreign_keys.each do |fk|
      execute "ALTER TABLE #{quote_table_name(fk[:source_table])} DROP CONSTRAINT #{quote_column_name(fk[:constraint_name])}"
    end

    dependent_constraints.each do |con|
      execute "ALTER TABLE #{quote_table_name(con[:table_name])} DROP CONSTRAINT #{quote_column_name(con[:constraint_name])}"
    end

    dependent_indexes.each do |idx|
      execute "DROP INDEX #{quote_column_name(idx[:index_name])}"
    end

    # 6. Swap primary key columns to uuid with gen_random_uuid() fallback default.
    target_tables.each do |table|
      pk_name = target_pk_map.fetch(table)
      quoted_table = quote_table_name(table)

      execute "ALTER TABLE #{quoted_table} DROP CONSTRAINT #{quote_column_name(pk_name)}"
      execute "ALTER TABLE #{quoted_table} DROP COLUMN #{quote_column_name('id')}"
      execute "ALTER TABLE #{quoted_table} RENAME COLUMN #{quote_column_name('__uuid_id')} TO #{quote_column_name('id')}"
      execute "ALTER TABLE #{quoted_table} ALTER COLUMN #{quote_column_name('id')} SET DEFAULT gen_random_uuid()"
      execute "ALTER TABLE #{quoted_table} ADD PRIMARY KEY (#{quote_column_name('id')})"
    end

    # 7. Swap all foreign key, unconstrained FK, and polymorphic columns to uuid.
    swap_reference_columns!(foreign_keys, unconstrained_fks, polymorphic_refs)

    # 8. Restore check/unique constraints, indexes, and foreign keys.
    dependent_constraints.each do |con|
      execute "ALTER TABLE #{quote_table_name(con[:table_name])} ADD CONSTRAINT #{quote_column_name(con[:constraint_name])} #{con[:definition]}"
    end

    dependent_indexes.each do |idx|
      execute idx[:definition]
    end

    foreign_keys.each do |fk|
      execute "ALTER TABLE #{quote_table_name(fk[:source_table])} ADD CONSTRAINT #{quote_column_name(fk[:constraint_name])} #{fk[:definition]}"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "UUIDv7 primary key migration is irreversible"
  end

  private

  def excluded_table?(table_name)
    EXCLUDED_TABLES.include?(table_name) || EXCLUDED_TABLE_PREFIXES.any? { |prefix| table_name.start_with?(prefix) }
  end

  def discover_target_tables
    rows = select_all(<<~SQL)
      SELECT c.relname AS table_name, con.conname AS pk_name
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_constraint con ON con.conrelid = c.oid AND con.contype = 'p'
      JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = con.conkey[1]
      JOIN pg_type t ON t.oid = a.atttypid
      WHERE n.nspname = current_schema()
        AND c.relkind = 'r'
        AND array_length(con.conkey, 1) = 1
        AND a.attname = 'id'
        AND t.typname IN ('int2', 'int4', 'int8')
      ORDER BY c.relname
    SQL

    rows.each_with_object({}) do |row, map|
      table = row["table_name"]
      next if excluded_table?(table)

      map[table] = row["pk_name"]
    end
  end

  def discover_foreign_keys(target_set)
    rows = select_all(<<~SQL)
      SELECT con.conname AS constraint_name,
             src.relname AS source_table,
             src_att.attname AS source_column,
             NOT src_att.attnotnull AS nullable,
             tgt.relname AS target_table,
             pg_get_constraintdef(con.oid) AS definition
      FROM pg_constraint con
      JOIN pg_class src ON src.oid = con.conrelid
      JOIN pg_namespace src_ns ON src_ns.oid = src.relnamespace
      JOIN pg_class tgt ON tgt.oid = con.confrelid
      JOIN pg_namespace tgt_ns ON tgt_ns.oid = tgt.relnamespace
      JOIN pg_attribute src_att ON src_att.attrelid = src.oid AND src_att.attnum = con.conkey[1]
      JOIN pg_attribute tgt_att ON tgt_att.attrelid = tgt.oid AND tgt_att.attnum = con.confkey[1]
      WHERE con.contype = 'f'
        AND src_ns.nspname = current_schema()
        AND tgt_ns.nspname = current_schema()
        AND array_length(con.conkey, 1) = 1
        AND array_length(con.confkey, 1) = 1
        AND tgt_att.attname = 'id'
      ORDER BY src.relname, con.conname
    SQL

    rows.filter_map do |row|
      next unless target_set.include?(row["target_table"])
      next if excluded_table?(row["source_table"])

      {
        constraint_name: row["constraint_name"],
        source_table: row["source_table"],
        source_column: row["source_column"],
        nullable: row["nullable"] == true || row["nullable"] == "t",
        target_table: row["target_table"],
        definition: row["definition"]
      }
    end
  end

  def discover_unconstrained_foreign_keys(target_set)
    UNCONSTRAINED_FOREIGN_KEYS.filter_map do |entry|
      next unless target_set.include?(entry[:target_table])

      row = select_one(<<~SQL)
        SELECT NOT a.attnotnull AS nullable
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        JOIN pg_type t ON t.oid = a.atttypid
        WHERE n.nspname = current_schema()
          AND c.relname = #{quote(entry[:source_table])}
          AND a.attname = #{quote(entry[:source_column])}
          AND a.attnum > 0
          AND NOT a.attisdropped
          AND t.typname IN ('int2', 'int4', 'int8')
      SQL
      next unless row

      entry.merge(nullable: row["nullable"] == true || row["nullable"] == "t")
    end
  end

  def discover_polymorphic_references(foreign_keys, unconstrained_fks)
    known_fk_cols = (foreign_keys + unconstrained_fks).map { |fk| [ fk[:source_table], fk[:source_column] ] }.to_set

    rows = select_all(<<~SQL)
      SELECT c.relname AS table_name,
             id_att.attname AS id_column,
             type_att.attname AS type_column,
             NOT id_att.attnotnull AS nullable
      FROM pg_class c
      JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_attribute id_att ON id_att.attrelid = c.oid
      JOIN pg_type id_type ON id_type.oid = id_att.atttypid
      JOIN pg_attribute type_att ON type_att.attrelid = c.oid
      JOIN pg_type type_type ON type_type.oid = type_att.atttypid
      WHERE n.nspname = current_schema()
        AND c.relkind = 'r'
        AND id_att.attnum > 0
        AND NOT id_att.attisdropped
        AND id_att.attname LIKE '%\\_id'
        AND id_type.typname IN ('int2', 'int4', 'int8')
        AND type_att.attnum > 0
        AND NOT type_att.attisdropped
        AND type_att.attname = substr(id_att.attname, 1, length(id_att.attname) - 3) || '_type'
        AND type_type.typname IN ('varchar', 'text', 'bpchar')
      ORDER BY c.relname, id_att.attname
    SQL

    rows.filter_map do |row|
      table = row["table_name"]
      col = row["id_column"]
      next if excluded_table?(table)
      next if known_fk_cols.include?([ table, col ])

      {
        table_name: table,
        id_column: col,
        type_column: row["type_column"],
        nullable: row["nullable"] == true || row["nullable"] == "t"
      }
    end
  end

  def build_converted_columns_map(target_tables, foreign_keys, unconstrained_fks, polymorphic_refs)
    map = Hash.new { |h, k| h[k] = Set.new }
    target_tables.each { |table| map[table] << "id" }
    foreign_keys.each { |fk| map[fk[:source_table]] << fk[:source_column] }
    unconstrained_fks.each { |fk| map[fk[:source_table]] << fk[:source_column] }
    polymorphic_refs.each { |ref| map[ref[:table_name]] << ref[:id_column] }
    map
  end

  def discover_dependent_constraints(affected_tables, converted_columns)
    constraints = []

    affected_tables.each do |table|
      cols = converted_columns.fetch(table)
      rows = select_all(<<~SQL)
        SELECT con.conname AS constraint_name,
               pg_get_constraintdef(con.oid) AS definition,
               array_to_string(
                 ARRAY(
                   SELECT a.attname
                   FROM unnest(con.conkey) AS k(attnum)
                   JOIN pg_attribute a ON a.attrelid = c.oid AND a.attnum = k.attnum
                 ),
                 ','
               ) AS column_list
        FROM pg_constraint con
        JOIN pg_class c ON c.oid = con.conrelid
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = current_schema()
          AND c.relname = #{quote(table)}
          AND con.contype IN ('c', 'u')
        ORDER BY con.conname
      SQL

      rows.each do |row|
        con_cols = row["column_list"].to_s.split(",")
        next unless con_cols.any? { |c| cols.include?(c) }

        constraints << {
          table_name: table,
          constraint_name: row["constraint_name"],
          definition: row["definition"]
        }
      end
    end

    constraints
  end

  def discover_dependent_indexes(affected_tables, converted_columns)
    indexes = []

    affected_tables.each do |table|
      cols = converted_columns.fetch(table).to_a
      col_literals = cols.map { |c| quote(c) }.join(", ")

      rows = select_all(<<~SQL)
        SELECT i.relname AS index_name,
               pg_get_indexdef(ix.indexrelid) AS definition
        FROM pg_index ix
        JOIN pg_class t ON t.oid = ix.indrelid
        JOIN pg_class i ON i.oid = ix.indexrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = current_schema()
          AND t.relname = #{quote(table)}
          AND NOT ix.indisprimary
          AND NOT EXISTS (
            SELECT 1 FROM pg_constraint con
            WHERE con.conindid = ix.indexrelid
          )
          AND (
            EXISTS (
              SELECT 1
              FROM unnest(ix.indkey) AS k(attnum)
              JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = k.attnum
              WHERE a.attname IN (#{col_literals})
            )
            OR EXISTS (
              SELECT 1
              FROM pg_depend d
              JOIN pg_attribute a ON a.attrelid = d.refobjid AND a.attnum = d.refobjsubid
              WHERE d.objid = ix.indexrelid
                AND d.refobjid = t.oid
                AND a.attname IN (#{col_literals})
            )
          )
        ORDER BY i.relname
      SQL

      rows.each do |row|
        indexes << {
          table_name: table,
          index_name: row["index_name"],
          definition: row["definition"]
        }
      end
    end

    indexes
  end

  def create_uuid_helper_functions!
    execute <<~SQL
      CREATE OR REPLACE FUNCTION pg_temp.magicbook_uuid_v7(ts timestamptz, seq bigint) RETURNS uuid
      LANGUAGE plpgsql VOLATILE AS $$
      DECLARE
        base_ms bigint;
        adj_ms bigint;
        sub_seq int;
        rand_hex text;
        variant_byte text;
      BEGIN
        base_ms := floor(extract(epoch FROM coalesce(ts, clock_timestamp())) * 1000)::bigint;
        adj_ms := base_ms + (seq / 4096);
        sub_seq := (seq % 4096)::int;
        rand_hex := replace(gen_random_uuid()::text, '-', '');
        variant_byte := lpad(to_hex((get_byte(decode(substr(rand_hex, 17, 2), 'hex'), 0) & 63) | 128), 2, '0');
        RETURN (
          lpad(to_hex(adj_ms), 12, '0')
          || '7'
          || lpad(to_hex(sub_seq), 3, '0')
          || variant_byte
          || substr(rand_hex, 19, 14)
        )::uuid;
      END;
      $$;
    SQL

    execute <<~SQL
      CREATE OR REPLACE FUNCTION pg_temp.magicbook_orphan_uuid(tbl text, old_id bigint) RETURNS uuid
      LANGUAGE plpgsql IMMUTABLE AS $$
      DECLARE
        h text;
        variant_byte text;
      BEGIN
        h := md5('magicbook-uuid-orphan:' || tbl || ':' || old_id::text);
        variant_byte := lpad(to_hex((get_byte(decode(substr(h, 17, 2), 'hex'), 0) & 63) | 128), 2, '0');
        RETURN (
          substr(h, 1, 12)
          || '5'
          || substr(h, 14, 3)
          || variant_byte
          || substr(h, 19, 14)
        )::uuid;
      END;
      $$;
    SQL
  end

  def backfill_primary_key_uuids!(table)
    quoted_table = quote_table_name(table)
    execute "ALTER TABLE #{quoted_table} ADD COLUMN #{quote_column_name('__uuid_id')} uuid"

    ts_col = TIMESTAMP_CANDIDATES.find { |candidate| column_exists?(table, candidate) }

    if ts_col
      quoted_ts = quote_column_name(ts_col)
      execute <<~SQL
        WITH numbered AS (
          SELECT id,
                 #{quoted_ts} AS ts,
                 row_number() OVER (
                   PARTITION BY floor(extract(epoch FROM coalesce(#{quoted_ts}, clock_timestamp())) * 1000)
                   ORDER BY id
                 ) - 1 AS seq
          FROM #{quoted_table}
        )
        UPDATE #{quoted_table} t
        SET "__uuid_id" = pg_temp.magicbook_uuid_v7(n.ts, n.seq)
        FROM numbered n
        WHERE t.id = n.id
      SQL
    else
      execute <<~SQL
        WITH anchor AS (
          SELECT clock_timestamp() AS ts
        ),
        numbered AS (
          SELECT t.id,
                 a.ts,
                 row_number() OVER (ORDER BY t.id) - 1 AS seq
          FROM #{quoted_table} t
          CROSS JOIN anchor a
        )
        UPDATE #{quoted_table} t
        SET "__uuid_id" = pg_temp.magicbook_uuid_v7(n.ts, n.seq)
        FROM numbered n
        WHERE t.id = n.id
      SQL
    end

    execute "ALTER TABLE #{quoted_table} ALTER COLUMN #{quote_column_name('__uuid_id')} SET NOT NULL"
  end

  def unique_fk_columns(foreign_keys)
    seen = Set.new
    foreign_keys.select { |fk| seen.add?([ fk[:source_table], fk[:source_column] ]) }
  end

  def backfill_foreign_key_uuids!(fk, allow_orphans:)
    source_table = quote_table_name(fk[:source_table])
    target_table = quote_table_name(fk[:target_table])
    source_col = quote_column_name(fk[:source_column])
    uuid_col = quote_column_name("__uuid_#{fk[:source_column]}")

    execute "ALTER TABLE #{source_table} ADD COLUMN #{uuid_col} uuid"

    execute <<~SQL
      UPDATE #{source_table} child
      SET #{uuid_col} = parent."__uuid_id"
      FROM #{target_table} parent
      WHERE child.#{source_col} = parent.id
    SQL

    if allow_orphans
      execute <<~SQL
        UPDATE #{source_table}
        SET #{uuid_col} = pg_temp.magicbook_orphan_uuid(#{quote(fk[:target_table])}, #{source_col})
        WHERE #{source_col} IS NOT NULL
          AND #{uuid_col} IS NULL
      SQL
    end

    unless fk[:nullable]
      execute "ALTER TABLE #{source_table} ALTER COLUMN #{uuid_col} SET NOT NULL"
    end
  end

  def backfill_polymorphic_uuids!(ref, target_set)
    table = quote_table_name(ref[:table_name])
    id_col = quote_column_name(ref[:id_column])
    type_col = quote_column_name(ref[:type_column])
    uuid_col = quote_column_name("__uuid_#{ref[:id_column]}")

    execute "ALTER TABLE #{table} ADD COLUMN #{uuid_col} uuid"

    distinct_types = select_values(<<~SQL)
      SELECT DISTINCT #{type_col}
      FROM #{table}
      WHERE NULLIF(BTRIM(#{type_col}), '') IS NOT NULL
        AND #{id_col} IS NOT NULL
    SQL

    distinct_types.each do |type_name|
      target_table = resolve_polymorphic_table(type_name)

      if target_table && target_set.include?(target_table)
        execute <<~SQL
          UPDATE #{table} child
          SET #{uuid_col} = parent."__uuid_id"
          FROM #{quote_table_name(target_table)} parent
          WHERE child.#{type_col} = #{quote(type_name)}
            AND child.#{id_col} = parent.id
        SQL
      end

      orphan_key = target_table || type_name
      execute <<~SQL
        UPDATE #{table}
        SET #{uuid_col} = pg_temp.magicbook_orphan_uuid(#{quote(orphan_key)}, #{id_col})
        WHERE #{type_col} = #{quote(type_name)}
          AND #{id_col} IS NOT NULL
          AND #{uuid_col} IS NULL
      SQL
    end

    execute <<~SQL
      UPDATE #{table}
      SET #{uuid_col} = pg_temp.magicbook_orphan_uuid(#{quote("#{ref[:table_name]}.#{ref[:id_column]}")}, #{id_col})
      WHERE #{id_col} IS NOT NULL
        AND #{uuid_col} IS NULL
    SQL

    unless ref[:nullable]
      execute "ALTER TABLE #{table} ALTER COLUMN #{uuid_col} SET NOT NULL"
    end
  end

  def resolve_polymorphic_table(type_name)
    return POLYMORPHIC_TABLE_OVERRIDES[type_name] if POLYMORPHIC_TABLE_OVERRIDES.key?(type_name)

    type_name.underscore.pluralize.tr("/", "_")
  end

  def log_migrated_books!
    rows = select_all('SELECT id, "__uuid_id", title FROM books ORDER BY id')
    return if rows.empty?

    say "Migrated books (update DEFAULT_BOOK_IDS with the new UUID):"
    rows.each do |row|
      say "  #{row['id']} -> #{row['__uuid_id']}, #{row['title']}", true
    end
  end

  def swap_reference_columns!(foreign_keys, unconstrained_fks, polymorphic_refs)
    columns_to_swap = []
    seen = Set.new

    (foreign_keys + unconstrained_fks).each do |fk|
      pair = [ fk[:source_table], fk[:source_column] ]
      columns_to_swap << pair if seen.add?(pair)
    end

    polymorphic_refs.each do |ref|
      pair = [ ref[:table_name], ref[:id_column] ]
      columns_to_swap << pair if seen.add?(pair)
    end

    columns_to_swap.each do |table, col|
      quoted_table = quote_table_name(table)
      quoted_col = quote_column_name(col)
      quoted_uuid = quote_column_name("__uuid_#{col}")

      execute "ALTER TABLE #{quoted_table} DROP COLUMN #{quoted_col}"
      execute "ALTER TABLE #{quoted_table} RENAME COLUMN #{quoted_uuid} TO #{quoted_col}"
    end
  end
end
