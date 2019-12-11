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

ActiveRecord::Schema.define(version: 2019_12_11_142326) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devices", id: false, force: :cascade do |t|
    t.string "device_id", null: false
    t.string "device_type"
    t.string "device_family"
    t.string "device_model"
    t.string "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_devices_on_device_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "device_id", null: false
    t.string "event_type"
    t.json "event_properties"
    t.json "user_properties"
    t.json "data"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "referrer"
    t.datetime "event_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uuid"], name: "index_events_on_uuid", unique: true
  end

  create_table "users", id: false, force: :cascade do |t|
    t.string "user_id", null: false
    t.string "email"
    t.string "ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_users_on_user_id", unique: true
  end

  add_foreign_key "devices", "users", primary_key: "user_id"
  add_foreign_key "events", "devices", primary_key: "device_id"
end
