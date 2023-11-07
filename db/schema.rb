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

ActiveRecord::Schema[7.0].define(version: 2023_11_06_143411) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_blacklists", force: :cascade do |t|
    t.string "file"
    t.string "category"
    t.integer "blacklist_type"
    t.integer "action"
    t.string "destination"
    t.string "domain"
    t.integer "kind"
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
    t.index ["feed_id"], name: "index_domains_on_feed_id"
  end

  create_table "feed_zones", force: :cascade do |t|
    t.bigint "feed_id"
    t.bigint "zone_id", null: false
    t.string "action"
    t.string "destination"
    t.string "file_path"
    t.string "zone_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_feed_zones_on_category_id"
    t.index ["feed_id"], name: "index_feed_zones_on_feed_id"
    t.index ["zone_id"], name: "index_feed_zones_on_zone_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.integer "blacklist_type"
    t.string "source"
    t.string "url"
    t.string "feed_name"
    t.string "feed_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_feeds_on_category_id"
  end

  create_table "zones", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "zone_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "domains", "feeds"
  add_foreign_key "feed_zones", "categories"
  add_foreign_key "feed_zones", "feeds"
  add_foreign_key "feed_zones", "zones"
  add_foreign_key "feeds", "categories"
end
