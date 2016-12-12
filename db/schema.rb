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

ActiveRecord::Schema.define(version: 20160212192915) do

  create_table "administrators", force: :cascade do |t|
    t.string   "name"
    t.string   "phone_number"
    t.integer  "data_center_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "email"
  end

  add_index "administrators", ["data_center_id"], name: "index_administrators_on_data_center_id"

  create_table "assistance_requests", force: :cascade do |t|
    t.integer  "incident_id"
    t.integer  "first_responder_id"
    t.integer  "state",               default: 0, null: false
    t.integer  "transportation_mode", default: 0, null: false
    t.datetime "eta"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "hospital_id"
  end

  add_index "assistance_requests", ["first_responder_id"], name: "index_assistance_requests_on_first_responder_id"
  add_index "assistance_requests", ["hospital_id"], name: "index_assistance_requests_on_hospital_id"
  add_index "assistance_requests", ["incident_id"], name: "index_assistance_requests_on_incident_id"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "data_center_permissions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "data_center_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "data_center_permissions", ["data_center_id"], name: "index_data_center_permissions_on_data_center_id"
  add_index "data_center_permissions", ["user_id"], name: "index_data_center_permissions_on_user_id"

  create_table "data_centers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_simulator", default: false, null: false
  end

  create_table "first_responder_event_logs", force: :cascade do |t|
    t.integer  "first_responder_id"
    t.string   "from_state"
    t.string   "to_state"
    t.datetime "event_time_stamp"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "incident_id"
  end

  add_index "first_responder_event_logs", ["first_responder_id"], name: "index_first_responder_event_logs_on_first_responder_id"
  add_index "first_responder_event_logs", ["incident_id"], name: "index_first_responder_event_logs_on_incident_id"

  create_table "first_responder_performance_data", force: :cascade do |t|
    t.integer  "first_responder_id",               null: false
    t.integer  "incident_id",                      null: false
    t.datetime "time_of_original_request"
    t.boolean  "did_reply_original_request"
    t.datetime "time_of_original_request_reply"
    t.datetime "time_of_additional_request"
    t.boolean  "did_reply_additional_request"
    t.datetime "time_of_additional_request_reply"
    t.integer  "eta"
    t.boolean  "was_assigned"
    t.boolean  "did_confirm_on_scene"
    t.datetime "time_of_confirm_on_scene"
    t.boolean  "did_cancel"
    t.boolean  "was_unable_to_locate"
    t.boolean  "was_incident_commander"
    t.boolean  "did_request_resources"
    t.integer  "vehicles_requested"
    t.boolean  "did_confirm_transport"
    t.datetime "time_of_confirm_transport"
    t.integer  "patients_transported"
    t.integer  "hospital_eta"
    t.integer  "hospital_id"
    t.boolean  "did_confirm_arrival"
    t.datetime "time_of_confirm_arrival"
    t.boolean  "did_complete"
    t.datetime "time_of_incident_complete"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "first_responder_performance_data", ["first_responder_id"], name: "index_first_responder_performance_data_on_first_responder_id"
  add_index "first_responder_performance_data", ["hospital_id"], name: "index_first_responder_performance_data_on_hospital_id"
  add_index "first_responder_performance_data", ["incident_id"], name: "index_first_responder_performance_data_on_incident_id"

  create_table "first_responders", force: :cascade do |t|
    t.integer  "state",               default: 1, null: false
    t.integer  "transportation_mode", default: 0, null: false
    t.string   "name"
    t.string   "phone_number",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
    t.integer  "data_center_id"
  end

  add_index "first_responders", ["data_center_id"], name: "index_first_responders_on_data_center_id"

  create_table "hospitals", force: :cascade do |t|
    t.integer  "data_center_id"
    t.string   "name"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "address",        default: "", null: false
  end

  add_index "hospitals", ["data_center_id"], name: "index_hospitals_on_data_center_id"

  create_table "incident_event_logs", force: :cascade do |t|
    t.integer  "incident_id"
    t.string   "from_state"
    t.string   "to_state"
    t.datetime "event_time_stamp"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "incident_event_logs", ["incident_id"], name: "index_incident_event_logs_on_incident_id"

  create_table "incidents", force: :cascade do |t|
    t.integer  "state"
    t.integer  "reporting_party_id"
    t.integer  "incident_commander_id"
    t.string   "location"
    t.integer  "completion_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "help_message"
    t.integer  "data_center_id"
    t.boolean  "is_accepting_first_responders",            default: false, null: false
    t.integer  "number_of_frs_to_allocate"
    t.integer  "number_of_transport_vehicles_to_allocate"
    t.text     "comment"
    t.integer  "subcategory_id"
  end

  add_index "incidents", ["data_center_id"], name: "index_incidents_on_data_center_id"
  add_index "incidents", ["incident_commander_id"], name: "index_incidents_on_incident_commander_id"
  add_index "incidents", ["reporting_party_id"], name: "index_incidents_on_reporting_party_id"
  add_index "incidents", ["subcategory_id"], name: "index_incidents_on_subcategory_id"

  create_table "medical_doctors", force: :cascade do |t|
    t.integer  "hospital_id"
    t.string   "name"
    t.string   "phone_number"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "medical_doctors", ["hospital_id"], name: "index_medical_doctors_on_hospital_id"

  create_table "message_logs", force: :cascade do |t|
    t.integer  "incident_id"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.string   "resource_name"
    t.string   "resource_phone_number"
    t.boolean  "is_incoming"
    t.string   "message"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "message_type",          default: 0
    t.string   "abridged_message"
  end

  add_index "message_logs", ["incident_id"], name: "index_message_logs_on_incident_id"

  create_table "reporting_parties", force: :cascade do |t|
    t.string   "phone_number"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "locale"
    t.boolean  "is_active",      default: true,  null: false
    t.integer  "data_center_id"
    t.integer  "state",          default: 0,     null: false
    t.boolean  "is_admin",       default: false, null: false
  end

  add_index "reporting_parties", ["data_center_id"], name: "index_reporting_parties_on_data_center_id"
  add_index "reporting_parties", ["phone_number"], name: "index_reporting_parties_on_phone_number"

  create_table "settings", force: :cascade do |t|
    t.string   "key",            null: false
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_center_id"
  end

  add_index "settings", ["data_center_id"], name: "index_settings_on_data_center_id"

  create_table "simulations", force: :cascade do |t|
    t.integer  "first_responder_count"
    t.integer  "incident_count"
    t.integer  "seed_value"
    t.boolean  "is_random",             default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "subcategories", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "subcategories", ["category_id"], name: "index_subcategories_on_category_id"

  create_table "unregistered_parties", force: :cascade do |t|
    t.string   "from"
    t.string   "to"
    t.string   "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "data_center_id"
    t.boolean  "is_admin",            default: false
    t.boolean  "is_deleted",          default: false
    t.string   "username",            default: "",    null: false
    t.string   "encrypted_password",  default: "",    null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "locale"
    t.string   "sid"
    t.integer  "user_role_id"
  end

  add_index "users", ["sid"], name: "index_users_on_sid", unique: true
  add_index "users", ["user_role_id"], name: "index_users_on_user_role_id"
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "white_listed_phone_numbers", force: :cascade do |t|
    t.integer  "data_center_id"
    t.string   "phone_number"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "white_listed_phone_numbers", ["data_center_id"], name: "index_white_listed_phone_numbers_on_data_center_id"

end
