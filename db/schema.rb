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

ActiveRecord::Schema[7.0].define(version: 2023_10_25_044047) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "domains", force: :cascade do |t|
    t.string "URL"
    t.text "list_domain"
    t.string "source"
    t.string "category"
    t.string "action"
    t.integer "status", default: 0
    t.integer "line_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "feed_id", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_domains_on_category_id"
    t.index ["feed_id"], name: "index_domains_on_feed_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "host"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rpzdata", force: :cascade do |t|
    t.string "domain"
    t.string "category"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "domain_id"
    t.index ["domain_id"], name: "index_rpzdata_on_domain_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "link"
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "domains", "categories"
  add_foreign_key "domains", "feeds"
end
