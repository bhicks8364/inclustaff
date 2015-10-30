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

ActiveRecord::Schema.define(version: 20151029182951) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "admins", force: :cascade do |t|
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
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "company_id"
    t.string   "role"
    t.string   "username"
    t.integer  "agency_id"
  end

  add_index "admins", ["company_id"], name: "index_admins_on_company_id", using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  add_index "admins", ["role"], name: "index_admins_on_role", using: :btree
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", unique: true, using: :btree

  create_table "agencies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "admin_id"
    t.string   "subdomain"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "phone_number"
    t.boolean  "free_trial"
    t.string   "contact_name"
    t.string   "contact_email"
    t.integer  "contact_id"
  end

  add_index "agencies", ["admin_id"], name: "index_agencies_on_admin_id", using: :btree
  add_index "agencies", ["contact_id"], name: "index_agencies_on_contact_id", using: :btree
  add_index "agencies", ["subdomain"], name: "index_agencies_on_subdomain", using: :btree

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
    t.integer  "user_id"
    t.integer  "agency_id"
    t.integer  "admin_id"
  end

  add_index "companies", ["admin_id"], name: "index_companies_on_admin_id", using: :btree
  add_index "companies", ["agency_id"], name: "index_companies_on_agency_id", using: :btree
  add_index "companies", ["user_id"], name: "index_companies_on_user_id", using: :btree

  create_table "company_admins", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.integer  "company_id"
    t.string   "role"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "company_admins", ["confirmation_token"], name: "index_company_admins_on_confirmation_token", unique: true, using: :btree
  add_index "company_admins", ["email"], name: "index_company_admins_on_email", unique: true, using: :btree
  add_index "company_admins", ["reset_password_token"], name: "index_company_admins_on_reset_password_token", unique: true, using: :btree
  add_index "company_admins", ["unlock_token"], name: "index_company_admins_on_unlock_token", unique: true, using: :btree

  create_table "employees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "email"
    t.string   "ssn"
    t.string   "phone_number"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "assigned"
    t.string   "resume_id"
    t.string   "desired_job_type"
    t.string   "desired_shift"
    t.hstore   "availablity"
  end

  add_index "employees", ["availablity"], name: "index_employees_on_availablity", using: :btree
  add_index "employees", ["deleted_at"], name: "index_employees_on_deleted_at", using: :btree
  add_index "employees", ["email"], name: "index_employees_on_email", using: :btree
  add_index "employees", ["user_id"], name: "index_employees_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "admin_id"
    t.string   "action"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "inquiries", force: :cascade do |t|
    t.string   "name"
    t.string   "job_title"
    t.string   "agency_name"
    t.string   "email"
    t.string   "agency_size"
    t.string   "phone_number"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "agency_id"
    t.integer  "week"
    t.datetime "due_by"
    t.boolean  "paid"
    t.decimal  "total"
    t.decimal  "amt_paid"
    t.datetime "date_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "invoices", ["agency_id"], name: "index_invoices_on_agency_id", using: :btree
  add_index "invoices", ["company_id"], name: "index_invoices_on_company_id", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.integer  "employee_id"
    t.integer  "order_id"
    t.string   "title"
    t.string   "description"
    t.date     "start_date"
    t.decimal  "pay_rate"
    t.date     "end_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.boolean  "active"
    t.datetime "deleted_at"
    t.integer  "recruiter_id"
    t.integer  "timesheets_count"
    t.hstore   "settings"
    t.text     "pay_types",                     array: true
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree
  add_index "jobs", ["pay_types"], name: "index_jobs_on_pay_types", using: :btree
  add_index "jobs", ["recruiter_id"], name: "index_jobs_on_recruiter_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "pay_range"
    t.text     "notes"
    t.integer  "number_needed"
    t.datetime "needed_by"
    t.boolean  "urgent"
    t.boolean  "active"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "title"
    t.datetime "deleted_at"
    t.integer  "manager_id"
    t.integer  "jobs_count"
    t.integer  "account_manager_id"
    t.decimal  "mark_up"
    t.integer  "agency_id"
    t.string   "dt_req"
    t.string   "bg_check"
    t.boolean  "heavy_lifting"
    t.boolean  "stwb"
    t.string   "est_duration"
    t.string   "shift"
    t.string   "bwc_code"
  end

  add_index "orders", ["account_manager_id"], name: "index_orders_on_account_manager_id", using: :btree
  add_index "orders", ["agency_id"], name: "index_orders_on_agency_id", using: :btree
  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree
  add_index "orders", ["manager_id"], name: "index_orders_on_manager_id", using: :btree

  create_table "resumes", force: :cascade do |t|
    t.string   "name"
    t.integer  "employee_id"
    t.text     "body"
    t.boolean  "active",      default: true
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "resumes", ["employee_id"], name: "index_resumes_on_employee_id", using: :btree

  create_table "shifts", force: :cascade do |t|
    t.datetime "time_in"
    t.datetime "time_out"
    t.integer  "employee_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.decimal  "time_worked"
    t.integer  "job_id"
    t.string   "state"
    t.decimal  "earnings"
    t.integer  "timesheet_id"
    t.datetime "deleted_at"
    t.string   "in_ip"
    t.string   "out_ip"
    t.integer  "week"
    t.text     "note"
    t.boolean  "needs_adj"
    t.decimal  "break_duration"
    t.text     "breaks",                      array: true
    t.datetime "break_in",                    array: true
    t.datetime "break_out",                   array: true
  end

  add_index "shifts", ["breaks"], name: "index_shifts_on_breaks", using: :btree
  add_index "shifts", ["deleted_at"], name: "index_shifts_on_deleted_at", using: :btree
  add_index "shifts", ["job_id"], name: "index_shifts_on_job_id", using: :btree
  add_index "shifts", ["timesheet_id"], name: "index_shifts_on_timesheet_id", using: :btree
  add_index "shifts", ["week"], name: "index_shifts_on_week", using: :btree

  create_table "skills", force: :cascade do |t|
    t.string   "name"
    t.boolean  "required",       default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "skillable_type"
    t.integer  "skillable_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "timesheets", force: :cascade do |t|
    t.integer  "week"
    t.integer  "job_id"
    t.decimal  "reg_hours"
    t.decimal  "ot_hours"
    t.decimal  "gross_pay"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.string   "state"
    t.integer  "approved_by"
    t.integer  "shifts_count"
    t.decimal  "total_bill"
    t.integer  "invoice_id"
    t.hstore   "adjustments"
  end

  add_index "timesheets", ["deleted_at"], name: "index_timesheets_on_deleted_at", using: :btree
  add_index "timesheets", ["invoice_id"], name: "index_timesheets_on_invoice_id", using: :btree
  add_index "timesheets", ["job_id"], name: "index_timesheets_on_job_id", using: :btree

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
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "deleted_at"
    t.boolean  "can_edit"
    t.string   "code"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.integer  "employee_id"
    t.integer  "agency_id"
    t.integer  "resume_id"
  end

  add_index "users", ["agency_id"], name: "index_users_on_agency_id", using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["resume_id"], name: "index_users_on_resume_id", using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

  create_table "work_histories", force: :cascade do |t|
    t.string   "employer_name"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "title"
    t.integer  "employee_id"
    t.text     "description"
    t.boolean  "current"
    t.boolean  "may_contact"
    t.string   "supervisor"
    t.string   "phone_number"
    t.string   "pay"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "work_histories", ["employee_id"], name: "index_work_histories_on_employee_id", using: :btree

end
