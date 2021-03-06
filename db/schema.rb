# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170823223436) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", id: :serial, force: :cascade do |t|
    t.string "title"
    t.string "version"
    t.string "pdf"
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_inclusions", force: :cascade do |t|
    t.bigint "card_id"
    t.string "piece_type"
    t.integer "piece_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_card_inclusions_on_card_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.integer "types"
    t.integer "colors"
    t.integer "converted_mana_cost"
    t.integer "multiverse_id"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chapters", force: :cascade do |t|
    t.string "title"
    t.text "subtitle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "citations", force: :cascade do |t|
    t.text "source"
    t.text "finding"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "editions", force: :cascade do |t|
    t.bigint "book_id"
    t.integer "major"
    t.integer "minor"
    t.integer "patch"
    t.text "note"
    t.datetime "release"
    t.string "pdf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_editions_on_book_id"
  end

  create_table "identifiers", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "email"
    t.bigint "magician_id"
    t.bigint "muggle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["magician_id"], name: "index_identifiers_on_magician_id"
    t.index ["muggle_id"], name: "index_identifiers_on_muggle_id"
  end

  create_table "listed_items", force: :cascade do |t|
    t.bigint "list_id"
    t.text "designation"
    t.text "expression"
    t.string "content_type"
    t.integer "content_id"
    t.integer "ordering"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "privacy"
    t.integer "replacing"
    t.index ["list_id"], name: "index_listed_items_on_list_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "magician_id"
    t.integer "mode"
    t.integer "privacy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "suggestability"
    t.integer "pin"
    t.index ["magician_id"], name: "index_lists_on_magician_id"
  end

  create_table "magicians", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token"
    t.datetime "authentication_token_created_at"
    t.index ["confirmation_token"], name: "index_magicians_on_confirmation_token", unique: true
    t.index ["email"], name: "index_magicians_on_email", unique: true
    t.index ["reset_password_token"], name: "index_magicians_on_reset_password_token", unique: true
  end

  create_table "muggles", force: :cascade do |t|
    t.string "email"
    t.bigint "magician_id"
    t.bigint "purchase_id"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_muggles_on_confirmation_token", unique: true
    t.index ["email"], name: "index_muggles_on_email", unique: true
    t.index ["magician_id"], name: "index_muggles_on_magician_id"
    t.index ["purchase_id"], name: "index_muggles_on_purchase_id"
    t.index ["reset_password_token"], name: "index_muggles_on_reset_password_token", unique: true
  end

  create_table "paragraphs", force: :cascade do |t|
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchased_books", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "purchase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_purchased_books_on_book_id"
    t.index ["purchase_id"], name: "index_purchased_books_on_purchase_id"
  end

  create_table "purchases", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "stripe_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "magician_id"
    t.string "token"
  end

  create_table "scribes", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_scribes_on_confirmation_token", unique: true
    t.index ["email"], name: "index_scribes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_scribes_on_reset_password_token", unique: true
  end

  create_table "sections", force: :cascade do |t|
    t.string "heading"
    t.text "subheading"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "table_of_contents", force: :cascade do |t|
    t.bigint "book_id"
    t.bigint "edition_id"
    t.bigint "chapter_id"
    t.bigint "section_id"
    t.bigint "paragraph_id"
    t.bigint "citation_id"
    t.integer "ordering"
    t.integer "flags", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_table_of_contents_on_book_id"
    t.index ["chapter_id"], name: "index_table_of_contents_on_chapter_id"
    t.index ["citation_id"], name: "index_table_of_contents_on_citation_id"
    t.index ["edition_id"], name: "index_table_of_contents_on_edition_id"
    t.index ["paragraph_id"], name: "index_table_of_contents_on_paragraph_id"
    t.index ["section_id"], name: "index_table_of_contents_on_section_id"
  end

  add_foreign_key "card_inclusions", "cards"
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
