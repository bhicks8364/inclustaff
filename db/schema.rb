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

ActiveRecord::Schema.define(version: 20160516214142) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "uuid-ossp"

  create_table "activities", force: :cascade do |t|
    t.integer  "trackable_id"
    t.string   "trackable_type"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "key"
    t.text     "parameters"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["owner_id", "owner_type"], name: "index_activities_on_owner_id_and_owner_type", using: :btree
  add_index "activities", ["recipient_id", "recipient_type"], name: "index_activities_on_recipient_id_and_recipient_type", using: :btree
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type", using: :btree

  create_table "adjustments", force: :cascade do |t|
    t.integer  "timesheet_id"
    t.string   "adj_type"
    t.decimal  "amount",       default: 0.0
    t.decimal  "pay_rate"
    t.decimal  "bill_rate"
    t.decimal  "hours",        default: 0.0
    t.boolean  "taxable",      default: false
    t.integer  "entered_by"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.decimal  "bill_amount",  default: 0.0
  end

  add_index "adjustments", ["timesheet_id"], name: "index_adjustments_on_timesheet_id", using: :btree

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
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "admins", ["company_id"], name: "index_admins_on_company_id", using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["invitation_token"], name: "index_admins_on_invitation_token", unique: true, using: :btree
  add_index "admins", ["invitations_count"], name: "index_admins_on_invitations_count", using: :btree
  add_index "admins", ["invited_by_id"], name: "index_admins_on_invited_by_id", using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  add_index "admins", ["role"], name: "index_admins_on_role", using: :btree
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", unique: true, using: :btree

  create_table "agencies", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
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
    t.string   "logo_url"
    t.hstore   "preferences",   default: {}
  end

  add_index "agencies", ["admin_id"], name: "index_agencies_on_admin_id", using: :btree
  add_index "agencies", ["contact_id"], name: "index_agencies_on_contact_id", using: :btree
  add_index "agencies", ["subdomain"], name: "index_agencies_on_subdomain", using: :btree

  create_table "breaks", force: :cascade do |t|
    t.integer  "shift_id"
    t.datetime "time_in"
    t.datetime "time_out"
    t.decimal  "duration"
    t.boolean  "paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.integer  "admin_id"
    t.integer  "company_admin_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "action"
    t.integer  "recipient_id"
    t.string   "recipient_type"
    t.boolean  "alert"
    t.datetime "read_at"
    t.hstore   "notify",           default: {}
  end

  add_index "comments", ["action"], name: "index_comments_on_action", using: :btree
  add_index "comments", ["admin_id"], name: "index_comments_on_admin_id", using: :btree
  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["company_admin_id"], name: "index_comments_on_company_admin_id", using: :btree
  add_index "comments", ["recipient_id"], name: "index_comments_on_recipient_id", using: :btree
  add_index "comments", ["recipient_type"], name: "index_comments_on_recipient_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "state"
    t.string   "zipcode"
    t.string   "contact_name"
    t.string   "contact_email"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "city"
    t.decimal  "balance"
    t.string   "phone_number"
    t.integer  "user_id"
    t.integer  "agency_id"
    t.integer  "admin_id"
    t.hstore   "preferences",   default: {}
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
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "company_admins", ["confirmation_token"], name: "index_company_admins_on_confirmation_token", unique: true, using: :btree
  add_index "company_admins", ["email"], name: "index_company_admins_on_email", unique: true, using: :btree
  add_index "company_admins", ["invitation_token"], name: "index_company_admins_on_invitation_token", unique: true, using: :btree
  add_index "company_admins", ["invitations_count"], name: "index_company_admins_on_invitations_count", using: :btree
  add_index "company_admins", ["invited_by_id"], name: "index_company_admins_on_invited_by_id", using: :btree
  add_index "company_admins", ["reset_password_token"], name: "index_company_admins_on_reset_password_token", unique: true, using: :btree
  add_index "company_admins", ["unlock_token"], name: "index_company_admins_on_unlock_token", unique: true, using: :btree

  create_table "direct_deposits", force: :cascade do |t|
    t.integer  "employee_id"
    t.string   "account_number"
    t.string   "routing_number"
    t.string   "acct_confirmation"
    t.string   "admin_id"
    t.datetime "effective_date"
    t.string   "account_type",      default: "Checking"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "direct_deposits", ["employee_id"], name: "index_direct_deposits_on_employee_id", using: :btree

  create_table "employees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "email"
    t.string   "ssn"
    t.string   "phone_number"
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.boolean  "assigned"
    t.string   "resume_id"
    t.string   "desired_job_type"
    t.string   "desired_shift"
    t.hstore   "availability"
    t.boolean  "dns",              default: false
    t.decimal  "exsisting_hours",  default: 0.0
    t.decimal  "aca_hours",        default: 0.0
    t.string   "status",           default: "New"
  end

  add_index "employees", ["availability"], name: "index_employees_on_availability", using: :btree
  add_index "employees", ["deleted_at"], name: "index_employees_on_deleted_at", using: :btree
  add_index "employees", ["email"], name: "index_employees_on_email", using: :btree
  add_index "employees", ["user_id"], name: "index_employees_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "admin_id"
    t.string   "action"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "user_id"
    t.integer  "agency_id"
    t.integer  "company_admin_id"
    t.datetime "read_at"
  end

  add_index "events", ["agency_id"], name: "index_events_on_agency_id", using: :btree
  add_index "events", ["company_admin_id"], name: "index_events_on_company_admin_id", using: :btree
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
    t.string   "ip_address"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "agency_id"
    t.datetime "due_by"
    t.boolean  "paid"
    t.decimal  "total"
    t.decimal  "amt_paid"
    t.datetime "date_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "week"
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
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "active"
    t.datetime "deleted_at"
    t.integer  "recruiter_id"
    t.integer  "timesheets_count"
    t.hstore   "settings"
    t.text     "pay_types",                                                  array: true
    t.hstore   "vacation"
    t.string   "state",            default: "Pending Approval"
  end

  add_index "jobs", ["deleted_at"], name: "index_jobs_on_deleted_at", using: :btree
  add_index "jobs", ["pay_types"], name: "index_jobs_on_pay_types", using: :btree
  add_index "jobs", ["recruiter_id"], name: "index_jobs_on_recruiter_id", using: :btree

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "is_delivered",               default: false
    t.string   "delivery_method"
    t.string   "message_id"
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "company_id"
    t.text     "notes"
    t.integer  "number_needed"
    t.datetime "needed_by"
    t.boolean  "urgent"
    t.boolean  "active"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
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
    t.decimal  "min_pay"
    t.decimal  "max_pay"
    t.string   "pay_frequency"
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "aca_type"
    t.hstore   "education",                 default: {}
    t.hstore   "requirements",              default: {}
    t.string   "industry"
    t.datetime "published_at"
    t.integer  "published_by"
    t.datetime "expires_at"
    t.boolean  "mobile_time_clock_enabled", default: false
    t.datetime "shift_start"
    t.datetime "shift_end"
    t.text     "account_manager_notes"
    t.text     "job_description"
    t.string   "payroll_code"
    t.string   "status"
  end

  add_index "orders", ["account_manager_id"], name: "index_orders_on_account_manager_id", using: :btree
  add_index "orders", ["agency_id"], name: "index_orders_on_agency_id", using: :btree
  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree
  add_index "orders", ["industry"], name: "index_orders_on_industry", using: :btree
  add_index "orders", ["manager_id"], name: "index_orders_on_manager_id", using: :btree
  add_index "orders", ["published_by"], name: "index_orders_on_published_by", using: :btree

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
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.decimal  "time_worked"
    t.integer  "job_id"
    t.string   "state"
    t.decimal  "earnings"
    t.integer  "timesheet_id"
    t.datetime "deleted_at"
    t.string   "in_ip"
    t.string   "out_ip"
    t.text     "note"
    t.boolean  "needs_adj"
    t.decimal  "break_duration"
    t.boolean  "paid_breaks",    default: false
    t.decimal  "pay_rate"
    t.float    "latitude"
    t.float    "longitude"
    t.date     "week"
  end

  add_index "shifts", ["deleted_at"], name: "index_shifts_on_deleted_at", using: :btree
  add_index "shifts", ["job_id"], name: "index_shifts_on_job_id", using: :btree
  add_index "shifts", ["timesheet_id"], name: "index_shifts_on_timesheet_id", using: :btree

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
    t.integer  "job_id"
    t.decimal  "reg_hours"
    t.decimal  "ot_hours"
    t.decimal  "gross_pay"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
    t.string   "state"
    t.integer  "approved_by"
    t.integer  "shifts_count"
    t.decimal  "total_bill"
    t.integer  "invoice_id"
    t.string   "approved_by_type"
    t.decimal  "total_hours"
    t.date     "week"
    t.decimal  "reg_bill_rate"
    t.decimal  "ot_bill_rate"
    t.date     "week_ending"
  end

  add_index "timesheets", ["approved_by_type"], name: "index_timesheets_on_approved_by_type", using: :btree
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
    t.datetime "checked_in_at"
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.date     "start_date"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["agency_id"], name: "index_users_on_agency_id", using: :btree
  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["resume_id"], name: "index_users_on_resume_id", using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "work_histories", force: :cascade do |t|
    t.integer "employee_id",                   null: false
    t.string  "employer_name"
    t.string  "title"
    t.date    "start_date"
    t.date    "end_date"
    t.text    "description"
    t.boolean "current",       default: false
    t.boolean "may_contact",   default: false
    t.string  "supervisor"
    t.string  "phone_number"
    t.string  "pay"
    t.string  "pay_period"
  end

  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
end
