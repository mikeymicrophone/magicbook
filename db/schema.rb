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

ActiveRecord::Schema.define(version: 20170630073911) do

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

  create_table "chapters", force: :cascade do |t|
    t.bigint "edition_id"
    t.integer "ordering"
    t.string "title"
    t.text "subtitle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_chapters_on_edition_id"
  end

  create_table "citations", force: :cascade do |t|
    t.bigint "paragraph_id"
    t.text "source"
    t.text "finding"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["paragraph_id"], name: "index_citations_on_paragraph_id"
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
    t.index ["confirmation_token"], name: "index_magicians_on_confirmation_token", unique: true
    t.index ["email"], name: "index_magicians_on_email", unique: true
    t.index ["reset_password_token"], name: "index_magicians_on_reset_password_token", unique: true
  end

  create_table "paragraphs", force: :cascade do |t|
    t.bigint "section_id"
    t.integer "ordering"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_paragraphs_on_section_id"
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
  end

  create_table "sections", force: :cascade do |t|
    t.bigint "chapter_id"
    t.integer "ordering"
    t.string "heading"
    t.text "subheading"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_sections_on_chapter_id"
  end

  add_foreign_key "chapters", "editions"
  add_foreign_key "citations", "paragraphs"
  add_foreign_key "editions", "books"
  add_foreign_key "paragraphs", "sections"
  add_foreign_key "purchased_books", "books"
  add_foreign_key "purchased_books", "purchases"
  add_foreign_key "sections", "chapters"
end
