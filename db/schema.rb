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

ActiveRecord::Schema.define(version: 20140828090959) do

  create_table "activities", force: true do |t|
    t.integer  "atype"
    t.boolean  "read",       default: false
    t.integer  "user_id",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.integer  "entry_id"
  end

  create_table "entries", force: true do |t|
    t.string   "title"
    t.string   "body"
    t.integer  "parent_id"
    t.integer  "np"
    t.integer  "user_id"
    t.boolean  "facilitation"
    t.boolean  "invisible"
    t.boolean  "top_fix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.string   "image"
  end

  create_table "exclusions", force: true do |t|
    t.string   "word"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: true do |t|
    t.string   "name"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "joins", force: true do |t|
    t.integer  "theme_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", force: true do |t|
    t.string   "word"
    t.float    "score",      limit: 24
    t.integer  "agree"
    t.integer  "disagree"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: true do |t|
    t.string   "title"
    t.string   "body"
    t.string   "color"
    t.boolean  "facilitation", default: false
    t.boolean  "nolink",       default: false
    t.boolean  "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_id"
    t.string   "image"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "realname",                              null: false
    t.integer  "role",                   default: 1
    t.string   "name",                                  null: false
    t.integer  "gender"
    t.integer  "age"
    t.string   "home"
    t.string   "move"
    t.boolean  "remind",                 default: true
    t.integer  "mail_format",            default: 0
    t.string   "image"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
