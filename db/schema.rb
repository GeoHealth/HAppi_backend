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

ActiveRecord::Schema.define(version: 20170503162451) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data_analysis_analysis_result_symptoms", force: :cascade do |t|
    t.integer "data_analysis_analysis_result_id"
    t.integer "symptom_id"
  end

  add_index "data_analysis_analysis_result_symptoms", ["data_analysis_analysis_result_id"], name: "index_data_analysis_analysis_result", using: :btree
  add_index "data_analysis_analysis_result_symptoms", ["symptom_id"], name: "index_data_analysis_analysis_result_symptoms_on_symptom_id", using: :btree

  create_table "data_analysis_analysis_results", force: :cascade do |t|
    t.integer "result_number"
    t.integer "data_analysis_analysis_users_having_same_symptom_id"
  end

  add_index "data_analysis_analysis_results", ["data_analysis_analysis_users_having_same_symptom_id"], name: "index_data_analysis_users_having_same_symptom", using: :btree

  create_table "data_analysis_basis_analyses", force: :cascade do |t|
    t.integer  "threshold"
    t.string   "token"
    t.string   "status"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_date"
    t.datetime "end_date"
  end

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
    t.string   "factor_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
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
    t.datetime "date"
    t.integer  "gps_coordinate_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "user_id"
  end

  add_index "occurrences", ["gps_coordinate_id"], name: "index_occurrences_on_gps_coordinate_id", using: :btree
  add_index "occurrences", ["symptom_id"], name: "index_occurrences_on_symptom_id", using: :btree
  add_index "occurrences", ["user_id"], name: "index_occurrences_on_user_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "email"
    t.datetime "expiration_date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "token"
    t.integer  "user_id"
  end

  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "shared_occurrences", force: :cascade do |t|
    t.integer "report_id"
    t.integer "occurrence_id"
  end

  add_index "shared_occurrences", ["occurrence_id"], name: "index_shared_occurrences_on_occurrence_id", using: :btree
  add_index "shared_occurrences", ["report_id"], name: "index_shared_occurrences_on_report_id", using: :btree

  create_table "symptoms", force: :cascade do |t|
    t.string   "name"
    t.string   "short_description"
    t.string   "long_description"
    t.string   "gender_filter"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "symptoms_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "symptom_id"
  end

  add_index "symptoms_users", ["symptom_id"], name: "index_symptoms_users_on_symptom_id", using: :btree
  add_index "symptoms_users", ["user_id", "symptom_id"], name: "index_symptoms_users_on_user_id_and_symptom_id", unique: true, using: :btree
  add_index "symptoms_users", ["user_id"], name: "index_symptoms_users_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.string   "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

  add_foreign_key "factor_instances", "factors"
  add_foreign_key "factor_instances", "occurrences"
  add_foreign_key "occurrences", "gps_coordinates"
  add_foreign_key "occurrences", "symptoms"
  add_foreign_key "occurrences", "users"
  add_foreign_key "symptoms_users", "symptoms"
  add_foreign_key "symptoms_users", "users"
end
