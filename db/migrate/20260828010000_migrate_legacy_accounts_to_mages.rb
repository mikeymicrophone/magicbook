class MigrateLegacyAccountsToMages < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:mages)

    migrate_magicians
    migrate_scribes
  end

  def down
    # Legacy rows and foreign keys are deliberately retained, so this backfill is
    # safe to leave in place if the schema ever needs to move backward.
  end

  private

  def migrate_magicians
    return unless table_exists?(:magicians)

    legacy_magicians.find_each do |magician|
      mage = migrate_account(magician, admin: false)
      next unless mage

      legacy_purchases.where(magician_id: magician.id, mage_id: nil).update_all(mage_id: mage.id)
      legacy_lists.where(magician_id: magician.id, mage_id: nil).update_all(mage_id: mage.id)
      legacy_identifiers.where(magician_id: magician.id, mage_id: nil).update_all(mage_id: mage.id)
    end
  end

  def migrate_scribes
    return unless table_exists?(:scribes)

    legacy_scribes.find_each do |scribe|
      # Scribes were the previous editing role. Let their credential win when an
      # address was also a reader account, and grant the equivalent Mage role.
      migrate_account(scribe, admin: true, prefer_legacy_password: true)
    end
  end

  def migrate_account(legacy_account, admin:, prefer_legacy_password: false)
    email = legacy_account.email.to_s.strip.downcase
    return if email.blank?

    mage = mages.where('LOWER(email) = ?', email).first
    encrypted_password = legacy_account.encrypted_password.presence

    if mage
      updates = {
        first_name: mage.first_name.presence || legacy_value(legacy_account, :first_name),
        last_name: mage.last_name.presence || legacy_value(legacy_account, :last_name),
        confirmed_at: mage.confirmed_at || legacy_value(legacy_account, :confirmed_at),
        confirmation_sent_at: mage.confirmation_sent_at || legacy_value(legacy_account, :confirmation_sent_at),
        admin: mage.admin? || admin
      }

      should_restore_password = encrypted_password.present? && (
        prefer_legacy_password || mage.confirmed_at.nil? || mage.must_set_password?
      )
      if should_restore_password
        updates[:encrypted_password] = encrypted_password
        updates[:must_set_password] = false
      end

      mage.update_columns(updates)
      return mage
    end

    mages.create!(
      email: email,
      encrypted_password: encrypted_password || '',
      first_name: legacy_value(legacy_account, :first_name),
      last_name: legacy_value(legacy_account, :last_name),
      confirmed_at: legacy_value(legacy_account, :confirmed_at),
      confirmation_sent_at: legacy_value(legacy_account, :confirmation_sent_at),
      admin: admin,
      must_set_password: encrypted_password.blank?,
      created_at: legacy_value(legacy_account, :created_at),
      updated_at: legacy_value(legacy_account, :updated_at)
    )
  end

  def mages
    @mages ||= migration_model(:mages)
  end

  def legacy_magicians
    @legacy_magicians ||= migration_model(:magicians)
  end

  def legacy_scribes
    @legacy_scribes ||= migration_model(:scribes)
  end

  def legacy_purchases
    @legacy_purchases ||= migration_model(:purchases)
  end

  def legacy_lists
    @legacy_lists ||= migration_model(:lists)
  end

  def legacy_identifiers
    @legacy_identifiers ||= migration_model(:identifiers)
  end

  def migration_model(table_name)
    Class.new(ActiveRecord::Base) do
      self.table_name = table_name
    end
  end

  def legacy_value(account, attribute)
    account.has_attribute?(attribute) ? account[attribute] : nil
  end
end
