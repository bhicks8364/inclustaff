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

ActiveRecord::Schema.define(version: 20150729182421) do

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "state"
    t.string   "zipcode"
    t.string   "contact_name"
    t.string   "contact_email"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "city"
    t.decimal  "balance"
    t.string   "phone_number"
  end

  create_table "employees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "email"
    t.string   "ssn"
    t.string   "phone_number"
  end

  add_index "employees", ["email"], name: "index_employees_on_email"

  create_table "jobs", force: :cascade do |t|
    t.integer  "employee_id"
    t.integer  "order_id"
    t.string   "title"
    t.string   "description"
    t.date     "start_date"
    t.decimal  "pay_rate"
    t.date     "end_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.boolean  "active"
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "pay_range"
    t.text     "notes"
    t.integer  "number_needed"
    t.datetime "needed_by"
    t.boolean  "urgent"
    t.boolean  "active"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "title"
  end

  create_table "shifts", force: :cascade do |t|
    t.datetime "time_in"
    t.datetime "time_out"
    t.integer  "employee_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.decimal  "time_worked"
    t.integer  "job_id"
    t.string   "state"
    t.decimal  "earnings"
    t.integer  "timesheet_id"
  end

  add_index "shifts", ["job_id"], name: "index_shifts_on_job_id"
  add_index "shifts", ["timesheet_id"], name: "index_shifts_on_timesheet_id"

  create_table "timesheets", force: :cascade do |t|
    t.integer  "week"
    t.integer  "job_id"
    t.decimal  "reg_hours"
    t.decimal  "ot_hours"
    t.decimal  "gross_pay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "timesheets", ["job_id"], name: "index_timesheets_on_job_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["role"], name: "index_users_on_role"

end
