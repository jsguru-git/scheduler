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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140110094656) do

  create_table "account_account_components", :force => true do |t|
    t.integer  "account_id"
    t.integer  "account_component_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "account_account_components", ["account_component_id", "account_id"], :name => "account_account_components_2"
  add_index "account_account_components", ["account_id", "account_component_id"], :name => "account_account_components_1"

  create_table "account_components", :force => true do |t|
    t.string   "name"
    t.integer  "price_in_cents"
    t.integer  "chargify_component_number"
    t.boolean  "show_component",            :default => true
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.text     "description"
    t.integer  "priority"
  end

  create_table "account_plans", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "price_in_cents"
    t.string   "chargify_product_handle"
    t.integer  "chargify_product_number"
    t.boolean  "show_plan",               :default => true
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "no_users"
  end

  add_index "account_plans", ["name"], :name => "index_account_plans_on_name"

  create_table "account_settings", :force => true do |t|
    t.integer  "account_id"
    t.boolean  "reached_limit_email_sent",           :default => false
    t.datetime "created_at",                                                            :null => false
    t.datetime "updated_at",                                                            :null => false
    t.time     "working_day_start_time",             :default => '2000-01-01 09:00:00'
    t.time     "working_day_end_time",               :default => '2000-01-01 17:00:00'
    t.integer  "common_project_id"
    t.string   "default_currency",                   :default => "usd"
    t.string   "working_days"
    t.string   "invoice_alert_email"
    t.string   "schedule_mail_email"
    t.integer  "schedule_mail_frequency",            :default => 1
    t.datetime "schedule_mail_last_sent_at"
    t.string   "expected_invoice_mail_email"
    t.integer  "expected_invoice_mail_frequency",    :default => 1
    t.datetime "expected_invoice_mail_last_sent_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_fingerprint"
    t.string   "rollover_alert_email"
    t.string   "budget_warning_email"
    t.string   "stale_opportunity_email"
    t.text     "issue_tracker_username"
    t.text     "issue_tracker_password"
    t.text     "issue_tracker_url"
    t.boolean  "hopscotch_enabled",                  :default => false
  end

  add_index "account_settings", ["account_id"], :name => "index_account_settings_on_account_id"
  add_index "account_settings", ["common_project_id"], :name => "index_account_settings_on_common_project_id"

  create_table "account_trial_emails", :force => true do |t|
    t.integer  "account_id"
    t.integer  "trial_path"
    t.boolean  "email_1_sent", :default => false
    t.boolean  "email_2_sent", :default => false
    t.boolean  "email_3_sent", :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "email_4_sent", :default => false
  end

  create_table "accounts", :force => true do |t|
    t.string   "site_address"
    t.datetime "account_deleted_at"
    t.boolean  "account_suspended",    :default => false
    t.integer  "account_plan_id"
    t.integer  "chargify_customer_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.datetime "trial_expires_at"
  end

  add_index "accounts", ["account_plan_id"], :name => "index_accounts_on_account_plan_id"
  add_index "accounts", ["chargify_customer_id"], :name => "index_accounts_on_chargify_customer_id", :unique => true
  add_index "accounts", ["site_address"], :name => "index_accounts_on_site_address", :unique => true

  create_table "api_keys", :force => true do |t|
    t.string   "access_token", :null => false
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "client_rate_cards", :force => true do |t|
    t.integer  "daily_cost_cents"
    t.integer  "client_id"
    t.integer  "rate_card_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "client_rate_cards", ["client_id", "rate_card_id"], :name => "index_client_rate_cards_on_client_id_and_rate_card_id"
  add_index "client_rate_cards", ["rate_card_id", "client_id"], :name => "index_client_rate_cards_on_rate_card_id_and_client_id"

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "archived",   :default => false
    t.text     "address"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "email"
    t.string   "fax"
    t.boolean  "internal",   :default => false
  end

  create_table "currencies", :force => true do |t|
    t.string   "iso_code"
    t.decimal  "exchange_rate", :precision => 11, :scale => 6
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "currencies", ["iso_code"], :name => "index_currencies_on_iso_code"

  create_table "document_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "document_id"
    t.text     "comment"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "document_comments", ["document_id"], :name => "index_document_comments_on_document_id"
  add_index "document_comments", ["user_id"], :name => "index_document_comments_on_user_id"

  create_table "documents", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "provider"
    t.text     "provider_document_ref"
    t.string   "provider_owner_names"
    t.string   "mime_type"
    t.text     "view_link"
    t.datetime "file_created_at"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "file_type"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "documents", ["project_id"], :name => "index_documents_on_project_id"
  add_index "documents", ["user_id"], :name => "index_documents_on_user_id"

  create_table "entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "account_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "entries", ["account_id"], :name => "index_entries_on_account_id"
  add_index "entries", ["project_id"], :name => "index_entries_on_project_id"
  add_index "entries", ["user_id"], :name => "index_entries_on_user_id"

  create_table "features", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "features", ["project_id"], :name => "index_features_on_project_id"

  create_table "invoice_deletions", :force => true do |t|
    t.integer  "project_id"
    t.integer  "account_id"
    t.integer  "user_id"
    t.integer  "default_currency_total_amount_cents_exc_vat"
    t.string   "invoice_number"
    t.date     "invoice_date"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "invoice_deletions", ["account_id"], :name => "index_invoice_deletions_on_account_id"
  add_index "invoice_deletions", ["project_id"], :name => "index_invoice_deletions_on_project_id"
  add_index "invoice_deletions", ["user_id"], :name => "index_invoice_deletions_on_user_id"

  create_table "invoice_items", :force => true do |t|
    t.string   "name"
    t.integer  "amount_cents",                  :default => 0
    t.integer  "quantity",                      :default => 1
    t.boolean  "vat",                           :default => true
    t.integer  "invoice_id"
    t.integer  "payment_profile_id"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.integer  "default_currency_amount_cents"
  end

  add_index "invoice_items", ["invoice_id", "payment_profile_id"], :name => "index_invoice_items_on_invoice_id_and_payment_profile_id"
  add_index "invoice_items", ["payment_profile_id", "invoice_id"], :name => "index_invoice_items_on_payment_profile_id_and_invoice_id"

  create_table "invoice_usages", :force => true do |t|
    t.string   "name"
    t.integer  "invoice_id"
    t.integer  "user_id"
    t.integer  "amount_cents"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.date     "allocated_at"
  end

  add_index "invoice_usages", ["invoice_id"], :name => "index_invoice_usages_on_invoice_id"
  add_index "invoice_usages", ["user_id"], :name => "index_invoice_usages_on_user_id"

  create_table "invoices", :force => true do |t|
    t.integer  "project_id"
    t.integer  "total_amount_cents_exc_vat"
    t.integer  "total_amount_cents_inc_vat"
    t.integer  "invoice_status",                                                             :default => 0
    t.date     "invoice_date"
    t.date     "due_on_date"
    t.string   "invoice_number"
    t.string   "terms"
    t.string   "po_number"
    t.string   "currency"
    t.decimal  "vat_rate",                                    :precision => 10, :scale => 2
    t.text     "address"
    t.text     "payment_methods"
    t.text     "notes"
    t.decimal  "exchange_rate",                               :precision => 10, :scale => 6
    t.datetime "created_at",                                                                                :null => false
    t.datetime "updated_at",                                                                                :null => false
    t.boolean  "pre_payment"
    t.integer  "default_currency_total_amount_cents_exc_vat"
    t.integer  "default_currency_total_amount_cents_inc_vat"
    t.string   "email"
    t.integer  "user_id"
  end

  add_index "invoices", ["invoice_number"], :name => "index_invoices_on_invoice_number"
  add_index "invoices", ["project_id"], :name => "index_invoices_on_project_id"
  add_index "invoices", ["user_id"], :name => "index_invoices_on_user_id"

  create_table "oauth_drive_tokens", :force => true do |t|
    t.integer  "user_id"
    t.integer  "provider_number"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "client_number"
    t.datetime "expires_at"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "oauth_drive_tokens", ["user_id"], :name => "index_oauth_drive_tokens_on_user_id"

  create_table "payment_profile_rollovers", :force => true do |t|
    t.text     "reason_for_date_change"
    t.date     "old_expected_payment_date"
    t.date     "new_expected_payment_date"
    t.integer  "payment_profile_id"
    t.integer  "project_id"
    t.integer  "account_id"
    t.integer  "user_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "payment_profile_rollovers", ["account_id"], :name => "index_payment_profile_rollovers_on_account_id"
  add_index "payment_profile_rollovers", ["payment_profile_id"], :name => "index_payment_profile_rollovers_on_payment_profile_id"
  add_index "payment_profile_rollovers", ["project_id"], :name => "index_payment_profile_rollovers_on_project_id"
  add_index "payment_profile_rollovers", ["user_id"], :name => "index_payment_profile_rollovers_on_user_id"

  create_table "payment_profiles", :force => true do |t|
    t.integer  "project_id"
    t.integer  "expected_cost_cents"
    t.decimal  "expected_minutes",        :precision => 20, :scale => 2
    t.string   "name"
    t.date     "expected_payment_date"
    t.boolean  "generate_cost_from_time",                                :default => false
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
  end

  add_index "payment_profiles", ["project_id"], :name => "index_payment_profiles_on_project_id"

  create_table "phases", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "project_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.text     "comment"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "project_comment_id"
  end

  add_index "project_comments", ["project_comment_id"], :name => "index_project_comments_on_project_comment_id"
  add_index "project_comments", ["project_id"], :name => "index_project_comments_on_project_id"
  add_index "project_comments", ["user_id"], :name => "index_project_comments_on_user_id"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "archived",                                                 :default => false
    t.integer  "account_id"
    t.integer  "client_id"
    t.datetime "created_at",                                                                      :null => false
    t.datetime "updated_at",                                                                      :null => false
    t.string   "color",                                                    :default => "#B7C18F"
    t.integer  "event_type",                                               :default => 0
    t.string   "project_code"
    t.integer  "team_id"
    t.integer  "business_owner_id"
    t.integer  "project_manager_id"
    t.integer  "current_rag_status",                                       :default => 0
    t.integer  "expected_rag_status",                                      :default => 0
    t.string   "project_status"
    t.boolean  "project_status_overridden"
    t.integer  "percentage_complete",                                      :default => 0
    t.decimal  "last_budget_check",         :precision => 11, :scale => 2, :default => 0.0
    t.string   "issue_tracker_id"
    t.integer  "phase_id"
  end

  add_index "projects", ["account_id", "client_id"], :name => "index_projects_on_account_id_and_client_id"
  add_index "projects", ["account_id", "name", "client_id"], :name => "index_projects_on_account_id_and_name_and_client_id"
  add_index "projects", ["business_owner_id"], :name => "index_projects_on_business_owner_id"
  add_index "projects", ["client_id"], :name => "index_projects_on_client_id"
  add_index "projects", ["project_manager_id"], :name => "index_projects_on_project_manager_id"
  add_index "projects", ["team_id"], :name => "index_projects_on_team_id"

  create_table "qa_stats", :force => true do |t|
    t.text     "ticket_breakdown"
    t.integer  "project_id"
    t.integer  "total_tickets"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "quote_activities", :force => true do |t|
    t.integer  "quote_id"
    t.integer  "rate_card_id"
    t.string   "name"
    t.integer  "estimate_scale",                                                    :default => 1
    t.integer  "min_estimated_minutes", :limit => 8,                                :default => 0
    t.integer  "max_estimated_minutes", :limit => 8,                                :default => 0
    t.integer  "min_amount_cents",      :limit => 8,                                :default => 0
    t.integer  "max_amount_cents",      :limit => 8,                                :default => 0
    t.integer  "position"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.integer  "estimate_type",                                                     :default => 0
    t.decimal  "discount_percentage",                :precision => 10, :scale => 2, :default => 0.0
  end

  add_index "quote_activities", ["quote_id"], :name => "index_quote_activities_on_quote_id"
  add_index "quote_activities", ["rate_card_id"], :name => "index_quote_activities_on_rate_card_id"

  create_table "quote_default_sections", :force => true do |t|
    t.integer  "account_id"
    t.integer  "position"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.boolean  "cost_section", :default => false
  end

  add_index "quote_default_sections", ["account_id"], :name => "index_quote_default_sections_on_account_id"

  create_table "quote_sections", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "position"
    t.integer  "quote_id"
    t.boolean  "cost_section", :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "quote_sections", ["quote_id"], :name => "index_quote_sections_on_quote_id"

  create_table "quotes", :force => true do |t|
    t.integer  "project_id"
    t.string   "title"
    t.decimal  "vat_rate",                 :precision => 10, :scale => 2
    t.decimal  "discount_percentage",      :precision => 10, :scale => 2
    t.boolean  "new_quote",                                               :default => true
    t.integer  "quote_id"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.string   "po_number"
    t.integer  "quote_status"
    t.string   "currency"
    t.integer  "user_id"
    t.integer  "last_saved_by_id"
    t.decimal  "exchange_rate",            :precision => 10, :scale => 6
    t.datetime "exchange_rate_updated_at"
    t.integer  "extra_cost_cents",                                        :default => 0
    t.string   "extra_cost_title"
    t.boolean  "draft",                                                   :default => true
  end

  add_index "quotes", ["last_saved_by_id"], :name => "index_quotes_on_last_saved_by_id"
  add_index "quotes", ["project_id"], :name => "index_quotes_on_project_id"
  add_index "quotes", ["quote_id"], :name => "index_quotes_on_quote_id"
  add_index "quotes", ["title"], :name => "index_quotes_on_title"
  add_index "quotes", ["user_id"], :name => "index_quotes_on_user_id"

  create_table "rate_card_payment_profiles", :force => true do |t|
    t.integer  "payment_profile_id"
    t.integer  "rate_card_id"
    t.integer  "percentage",         :default => 0
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "rate_card_payment_profiles", ["payment_profile_id", "rate_card_id"], :name => "rate_card_profile_in2"
  add_index "rate_card_payment_profiles", ["rate_card_id", "payment_profile_id"], :name => "rate_card_profile_in1"

  create_table "rate_cards", :force => true do |t|
    t.string   "service_type"
    t.integer  "daily_cost_cents"
    t.integer  "account_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "rate_cards", ["account_id"], :name => "index_rate_cards_on_account_id"

  create_table "roles", :force => true do |t|
    t.string "title"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "tasks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "project_id"
    t.integer  "estimated_minutes",         :limit => 8, :default => 0
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.integer  "feature_id"
    t.integer  "position"
    t.boolean  "count_towards_time_worked",              :default => true
    t.integer  "estimate_scale",                         :default => 1
    t.integer  "quote_activity_id"
    t.integer  "rate_card_id"
    t.boolean  "archived",                               :default => false
  end

  add_index "tasks", ["feature_id"], :name => "index_tasks_on_feature_id"
  add_index "tasks", ["project_id", "feature_id"], :name => "index_tasks_on_project_id_and_feature_id"

  create_table "team_users", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "team_users", ["team_id", "user_id"], :name => "index_team_users_on_team_id_and_user_id"
  add_index "team_users", ["user_id", "team_id"], :name => "index_team_users_on_user_id_and_team_id"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.integer  "account_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "teams", ["account_id"], :name => "index_teams_on_account_id"

  create_table "timings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "duration_minutes"
    t.integer  "project_id"
    t.integer  "task_id"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.boolean  "submitted",        :default => false
    t.text     "notes"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "timings", ["project_id"], :name => "index_timings_on_project_id"
  add_index "timings", ["task_id"], :name => "index_timings_on_task_id"
  add_index "timings", ["user_id"], :name => "index_timings_on_user_id"

  create_table "tweets", :force => true do |t|
    t.integer  "tweet_id_ref", :limit => 8
    t.string   "title"
    t.string   "user_name"
    t.datetime "published_at"
    t.boolean  "active",                    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "top_priority"
  end

  create_table "users", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "password_digest"
    t.string   "password_reset_code"
    t.integer  "account_id"
    t.datetime "last_login_at"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.string   "time_zone"
    t.boolean  "archived",                                :default => false
    t.text     "biography"
    t.integer  "number_of_logins",                        :default => 0
  end

  add_index "users", ["account_id", "firstname", "lastname"], :name => "index_users_on_account_id_and_firstname_and_lastname"

end
