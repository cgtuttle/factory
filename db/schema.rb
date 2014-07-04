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

ActiveRecord::Schema.define(:version => 20140704181746) do

  create_table "analyses", :force => true do |t|
    t.string   "code",         :limit => 64,                     :null => false
    t.string   "name",         :limit => 128
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                     :default => false
    t.datetime "deleted_at"
    t.integer  "tenant_id"
  end

  add_index "analyses", ["tenant_id", "code"], :name => "test_by_code", :unique => true
  add_index "analyses", ["tenant_id"], :name => "index_analyses_on_tenant_id"

  create_table "categories", :force => true do |t|
    t.string   "code",          :limit => 64,  :null => false
    t.string   "name",          :limit => 256
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tenant_id"
  end

  add_index "categories", ["tenant_id", "code"], :name => "category_by_code", :unique => true
  add_index "categories", ["tenant_id"], :name => "index_categories_on_tenant_id"

  create_table "cells", :force => true do |t|
    t.integer "import_id"
    t.integer "row_num"
    t.integer "col_num"
    t.text    "field_value"
    t.string  "field_name"
    t.boolean "had_save_error"
    t.string  "save_error_text"
    t.boolean "id_match"
    t.string  "import_value"
    t.integer "id_value"
    t.integer "import_row_id"
    t.integer "tenant_id"
  end

  create_table "import_rows", :force => true do |t|
    t.integer "import_id"
    t.boolean "import_error"
    t.integer "row_id"
    t.integer "tenant_id"
  end

  create_table "imports", :force => true do |t|
    t.integer "user_id"
    t.string  "model"
    t.integer "first_row"
    t.integer "row_count"
    t.integer "tenant_id"
  end

  create_table "items", :force => true do |t|
    t.string   "code",       :limit => 64,                     :null => false
    t.string   "name",       :limit => 128
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                   :default => false
    t.datetime "deleted_at"
    t.integer  "tenant_id"
  end

  add_index "items", ["tenant_id", "code"], :name => "item_by_code", :unique => true
  add_index "items", ["tenant_id"], :name => "index_items_on_tenant_id"

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tenant_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "role_id"
  end

  add_index "memberships", ["user_id", "tenant_id"], :name => "index_memberships_on_user_id_and_tenant_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "role_name"
    t.integer  "display_order"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.boolean  "viewable"
  end

  create_table "specifications", :force => true do |t|
    t.integer  "item_id"
    t.integer  "trait_id"
    t.integer  "version",                        :default => 1
    t.date     "eff_date"
    t.string   "tag"
    t.integer  "analysis_id"
    t.string   "changed_by"
    t.decimal  "numeric_value"
    t.string   "string_value"
    t.text     "text_value"
    t.string   "document_title"
    t.string   "document_url"
    t.string   "document_version", :limit => 32
    t.decimal  "lsl"
    t.decimal  "usl"
    t.string   "unit_of_measure",  :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                        :default => false
    t.boolean  "canceled",                       :default => false
    t.text     "notes"
  end

  create_table "tenants", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "traits", :force => true do |t|
    t.string   "code",          :limit => 64,                     :null => false
    t.string   "name",          :limit => 128
    t.integer  "usl"
    t.integer  "lsl"
    t.string   "label",         :limit => 64
    t.integer  "display_order",                :default => 0
    t.string   "created_by"
    t.string   "changed_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.boolean  "deleted",                      :default => false
    t.datetime "deleted_at"
    t.integer  "tenant_id"
  end

  add_index "traits", ["tenant_id", "code"], :name => "trait_by_code", :unique => true
  add_index "traits", ["tenant_id"], :name => "index_traits_on_tenant_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "", :null => false
    t.string   "encrypted_password",                   :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.date     "invitation_created_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token", :unique => true
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
