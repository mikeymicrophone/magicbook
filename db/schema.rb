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

ActiveRecord::Schema.define(version: 20170626205712) do

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
  end

  add_foreign_key "editions", "books"
  add_foreign_key "purchased_books", "books"
  add_foreign_key "purchased_books", "purchases"
end
