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

ActiveRecord::Schema[7.1].define(version: 2024_09_03_072729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.text "title"
    t.text "author"
    t.text "genre"
    t.text "summary"
    t.text "short_summary"
    t.integer "publication_year"
    t.text "cover_image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bookstore_books", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "bookstore_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_bookstore_books_on_book_id"
    t.index ["bookstore_id"], name: "index_bookstore_books_on_bookstore_id"
  end

  create_table "bookstores", force: :cascade do |t|
    t.text "name"
    t.text "address"
    t.boolean "availability"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "read_books", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_read_books_on_book_id"
    t.index ["user_id"], name: "index_read_books_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.bigint "read_book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["read_book_id"], name: "index_reviews_on_read_book_id"
  end

  create_table "user_libraries", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_user_libraries_on_book_id"
    t.index ["user_id"], name: "index_user_libraries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookstore_books", "books"
  add_foreign_key "bookstore_books", "bookstores"
  add_foreign_key "read_books", "books"
  add_foreign_key "read_books", "users"
  add_foreign_key "reviews", "read_books"
  add_foreign_key "user_libraries", "books"
  add_foreign_key "user_libraries", "users"
end
