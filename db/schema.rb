# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161215121952) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "factor_instances", force: :cascade do |t|
    t.integer  "factor_id"
    t.string   "value"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "occurrence_id"
  end

  add_index "factor_instances", ["factor_id"], name: "index_factor_instances_on_factor_id", using: :btree
  add_index "factor_instances", ["occurrence_id"], name: "index_factor_instances_on_occurrence_id", using: :btree

  create_table "factors", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gps_coordinates", force: :cascade do |t|
    t.float    "accuracy"
    t.float    "altitude"
    t.float    "altitude_accuracy"
    t.float    "heading"
    t.float    "speed"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "occurrences", force: :cascade do |t|
    t.integer  "symptom_id"
    t.string   "date"
    t.integer  "gps_coordinate_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "occurrences", ["gps_coordinate_id"], name: "index_occurrences_on_gps_coordinate_id", using: :btree
  add_index "occurrences", ["symptom_id"], name: "index_occurrences_on_symptom_id", using: :btree

  create_table "symptoms", force: :cascade do |t|
    t.string   "name"
    t.string   "short_description"
    t.string   "long_description"
    t.string   "gender_filter"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_foreign_key "factor_instances", "factors"
  add_foreign_key "factor_instances", "occurrences"
  add_foreign_key "occurrences", "gps_coordinates"
  add_foreign_key "occurrences", "symptoms"
end
