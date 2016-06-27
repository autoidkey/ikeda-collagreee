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

ActiveRecord::Schema.define(version: 20160201235112) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: true do |t|
    t.integer  "atype"
    t.boolean  "read",       default: false
    t.integer  "user_id",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.integer  "entry_id"
  end

  create_table "comment_menus", force: true do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "entries", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "parent_id"
    t.integer  "np",           default: 0
    t.integer  "user_id"
    t.boolean  "facilitation", default: false
    t.boolean  "invisible",    default: false
    t.boolean  "top_fix",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.string   "image"
    t.integer  "has_point"
    t.integer  "has_reply"
    t.string   "stamp"
    t.boolean  "agreement"
    t.integer  "claster"
  end

  add_index "entries", ["parent_id"], name: "index_entries_on_parent_id", using: :btree
  add_index "entries", ["updated_at"], name: "index_entries_on_updated_at", using: :btree

  create_table "exclusions", force: true do |t|
    t.string   "word"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facilitation_infomations", force: true do |t|
    t.text     "body"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facilitation_keywords", force: true do |t|
    t.integer  "theme_id"
    t.string   "word"
    t.float    "score",      limit: 24
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
    t.integer  "theme_id"
    t.integer  "user_id"
  end

  create_table "likes", force: true do |t|
    t.integer  "entry_id"
    t.integer  "user_id"
    t.integer  "theme_id"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "version_id"
    t.integer  "menu_id"
  end

  create_table "menus", force: true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "time_at"
    t.integer  "agreement"
    t.integer  "user_id"
    t.integer  "theme_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order"
    t.string   "image"
  end

  create_table "model_accesses", force: true do |t|
    t.integer  "theme_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", force: true do |t|
    t.integer  "ntype"
    t.integer  "user_id"
    t.boolean  "read"
    t.integer  "point_history_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.integer  "entry_id"
  end

  create_table "phases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
    t.integer  "phase_id"
  end

  create_table "point_histories", force: true do |t|
    t.integer  "user_id"
    t.integer  "entry_id"
    t.integer  "theme_id"
    t.integer  "activity_id"
    t.float    "point",       limit: 24
    t.integer  "atype"
    t.integer  "action"
    t.integer  "depth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "like_id"
    t.integer  "version_id"
    t.integer  "reply_id"
  end

  create_table "points", force: true do |t|
    t.integer  "theme_id"
    t.integer  "user_id"
    t.boolean  "latest"
    t.integer  "entry"
    t.integer  "reply"
    t.integer  "like"
    t.integer  "replied"
    t.integer  "liked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sum"
  end

  create_table "tagayashis", force: true do |t|
    t.integer  "user_id"
    t.integer  "theme_id"
    t.text     "think"
    t.text     "people"
    t.text     "place"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tagged_entries", force: true do |t|
    t.integer  "entry_id",   null: false
    t.integer  "issue_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "theme_accesses", force: true do |t|
    t.integer  "theme_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: true do |t|
    t.string   "title"
    t.string   "body"
    t.string   "color"
    t.boolean  "facilitation",   default: false
    t.boolean  "nolink",         default: false
    t.boolean  "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_id"
    t.string   "image"
    t.boolean  "point_function", default: true
    t.text     "other_body"
    t.integer  "owner_id"
    t.integer  "theme_type"
    t.string   "team"
    t.string   "place"
    t.datetime "started_at"
  end

  create_table "tree_logs", force: true do |t|
    t.integer  "user_id"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "targer_id"
  end

  create_table "treedata", force: true do |t|
    t.integer  "user_id"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "realname",                            null: false
    t.integer  "role",                   default: 2
    t.string   "name",                                null: false
    t.integer  "gender"
    t.integer  "age"
    t.integer  "home",                   default: 0
    t.integer  "move",                   default: 0
    t.integer  "remind",                 default: 0
    t.integer  "mail_format",            default: 0
    t.string   "image"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "webviews", force: true do |t|
    t.integer  "user_id"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "webviews", ["theme_id"], name: "index_webviews_on_theme_id", using: :btree
  add_index "webviews", ["user_id"], name: "index_webviews_on_user_id", using: :btree

  create_table "youyakudata", force: true do |t|
    t.integer  "target_id"
    t.integer  "thread_id"
    t.integer  "theme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body"
  end

  create_table "youyakus", force: true do |t|
    t.string   "body"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id"
  end

end
