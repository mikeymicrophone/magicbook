# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_03_010000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "books", id: :serial, force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", precision: nil, null: false
    t.string "pdf"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "version"
  end

  create_table "card_concepts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "oracle_id"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_card_concepts_on_name", unique: true
    t.index ["oracle_id"], name: "index_card_concepts_on_oracle_id", unique: true, where: "(oracle_id IS NOT NULL)"
  end

  create_table "card_function_assignments", force: :cascade do |t|
    t.bigint "card_concept_id", null: false
    t.bigint "card_function_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_concept_id", "card_function_id"], name: "index_card_function_assignments_on_concept_and_function", unique: true
    t.index ["card_concept_id"], name: "index_card_function_assignments_on_card_concept_id"
    t.index ["card_function_id"], name: "index_card_function_assignments_on_card_function_id"
  end

  create_table "card_function_relations", force: :cascade do |t|
    t.bigint "child_function_id", null: false
    t.datetime "created_at", null: false
    t.bigint "parent_function_id", null: false
    t.datetime "updated_at", null: false
    t.index ["child_function_id"], name: "index_card_function_relations_on_child_function_id"
    t.index ["parent_function_id", "child_function_id"], name: "index_card_function_relations_on_parent_and_child", unique: true
    t.index ["parent_function_id"], name: "index_card_function_relations_on_parent_function_id"
  end

  create_table "card_functions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_card_functions_on_name", unique: true
    t.index ["slug"], name: "index_card_functions_on_slug", unique: true
  end

  create_table "card_inclusions", force: :cascade do |t|
    t.bigint "card_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "piece_id"
    t.string "piece_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_id"], name: "index_card_inclusions_on_card_id"
  end

  create_table "card_sets", force: :cascade do |t|
    t.integer "category", default: 6, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.date "released_on"
    t.string "set_type"
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_card_sets_on_category"
    t.index ["code"], name: "index_card_sets_on_code", unique: true
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "card_concept_id", null: false
    t.bigint "card_set_id"
    t.string "collector_number"
    t.integer "colors"
    t.integer "converted_mana_cost"
    t.datetime "created_at", precision: nil, null: false
    t.string "image_url"
    t.integer "multiverse_id"
    t.string "name"
    t.boolean "preferred", default: false, null: false
    t.date "released_on"
    t.string "scryfall_id"
    t.integer "types"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["card_concept_id", "card_set_id"], name: "index_cards_on_concept_and_set", unique: true, where: "(card_set_id IS NOT NULL)"
    t.index ["card_concept_id"], name: "index_cards_on_card_concept_id"
    t.index ["card_concept_id"], name: "index_cards_on_preferred_concept", unique: true, where: "preferred"
    t.index ["card_set_id"], name: "index_cards_on_card_set_id"
    t.index ["scryfall_id"], name: "index_cards_on_scryfall_id", unique: true, where: "(scryfall_id IS NOT NULL)"
  end

  create_table "chapters", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "subtitle"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "citations", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "finding"
    t.text "source"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "editions", force: :cascade do |t|
    t.bigint "book_id"
    t.datetime "created_at", precision: nil, null: false
    t.integer "major"
    t.integer "minor"
    t.text "note"
    t.integer "patch"
    t.string "pdf"
    t.datetime "release", precision: nil
    t.datetime "updated_at", precision: nil, null: false
    t.index ["book_id"], name: "index_editions_on_book_id"
  end

  create_table "identifiers", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.bigint "magician_id"
    t.bigint "muggle_id"
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["magician_id"], name: "index_identifiers_on_magician_id"
    t.index ["muggle_id"], name: "index_identifiers_on_muggle_id"
  end

  create_table "listed_items", force: :cascade do |t|
    t.integer "content_id"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.text "designation"
    t.text "expression"
    t.bigint "list_id"
    t.integer "ordering"
    t.integer "privacy"
    t.integer "replacing"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["list_id"], name: "index_listed_items_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "description"
    t.bigint "magician_id"
    t.integer "mode"
    t.string "name"
    t.integer "pin"
    t.integer "privacy"
    t.integer "suggestability"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["magician_id"], name: "index_lists_on_magician_id"
  end

  create_table "magicians", force: :cascade do |t|
    t.string "authentication_token"
    t.datetime "authentication_token_created_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_magicians_on_confirmation_token", unique: true
    t.index ["email"], name: "index_magicians_on_email", unique: true
    t.index ["reset_password_token"], name: "index_magicians_on_reset_password_token", unique: true
  end

  create_table "muggles", force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.bigint "magician_id"
    t.bigint "purchase_id"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_muggles_on_confirmation_token", unique: true
    t.index ["email"], name: "index_muggles_on_email", unique: true
    t.index ["magician_id"], name: "index_muggles_on_magician_id"
    t.index ["purchase_id"], name: "index_muggles_on_purchase_id"
    t.index ["reset_password_token"], name: "index_muggles_on_reset_password_token", unique: true
  end

  create_table "paragraphs", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "text"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "purchased_books", force: :cascade do |t|
    t.bigint "book_id"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "purchase_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["book_id"], name: "index_purchased_books_on_book_id"
    t.index ["purchase_id"], name: "index_purchased_books_on_purchase_id"
  end

  create_table "purchases", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.bigint "magician_id"
    t.string "stripe_token"
    t.string "token"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "scribes", force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_scribes_on_confirmation_token", unique: true
    t.index ["email"], name: "index_scribes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_scribes_on_reset_password_token", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "heading"
    t.text "subheading"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "table_of_contents", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "chapter_id"
    t.bigint "citation_id"
    t.datetime "created_at", precision: nil, null: false
    t.bigint "edition_id"
    t.integer "flags", default: 0, null: false
    t.integer "ordering"
    t.bigint "paragraph_id"
    t.bigint "section_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["book_id"], name: "index_table_of_contents_on_book_id"
    t.index ["chapter_id"], name: "index_table_of_contents_on_chapter_id"
    t.index ["citation_id"], name: "index_table_of_contents_on_citation_id"
    t.index ["edition_id"], name: "index_table_of_contents_on_edition_id"
    t.index ["paragraph_id"], name: "index_table_of_contents_on_paragraph_id"
    t.index ["section_id"], name: "index_table_of_contents_on_section_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "card_function_assignments", "card_concepts"
  add_foreign_key "card_function_assignments", "card_functions"
  add_foreign_key "card_function_relations", "card_functions", column: "child_function_id"
  add_foreign_key "card_function_relations", "card_functions", column: "parent_function_id"
  add_foreign_key "card_inclusions", "cards"
  add_foreign_key "cards", "card_concepts"
  add_foreign_key "cards", "card_sets"
  add_foreign_key "editions", "books"
  add_foreign_key "purchased_books", "books"
  add_foreign_key "purchased_books", "purchases"
  add_foreign_key "table_of_contents", "books"
  add_foreign_key "table_of_contents", "chapters"
  add_foreign_key "table_of_contents", "citations"
  add_foreign_key "table_of_contents", "editions"
  add_foreign_key "table_of_contents", "paragraphs"
  add_foreign_key "table_of_contents", "sections"
end
