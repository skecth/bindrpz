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

ActiveRecord::Schema[7.0].define(version: 2023_11_29_045829) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_blacklists", force: :cascade do |t|
    t.string "file"
    t.integer "blacklist_type"
    t.integer "action"
    t.string "destination"
    t.string "domain"
    t.integer "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "zone_id", null: false
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_custom_blacklists_on_category_id"
    t.index ["zone_id"], name: "index_custom_blacklists_on_zone_id"
  end

  create_table "feed_zones", force: :cascade do |t|
    t.bigint "feed_id"
    t.bigint "zone_id", null: false
    t.string "selected_action"
    t.string "destination"
    t.string "file_path"
    t.string "zone_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.boolean "enable_disable_status", default: true
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
    t.integer "number_of_blacklist", default: 0
    t.integer "number_of_domain", default: 0
    t.index ["category_id"], name: "index_feeds_on_category_id"
  end

  create_table "zones", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "zone_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "custom_blacklists", "categories"
  add_foreign_key "custom_blacklists", "zones"
  add_foreign_key "feed_zones", "categories"
  add_foreign_key "feed_zones", "feeds"
  add_foreign_key "feed_zones", "zones"
  add_foreign_key "feeds", "categories"
end
