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

ActiveRecord::Schema.define(version: 20161027095322) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: :cascade do |t|
    t.integer  "atype",      limit: 4
    t.boolean  "read",                 default: false
    t.integer  "user_id",    limit: 4,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",   limit: 4
    t.integer  "entry_id",   limit: 4
  end

  create_table "core_times", force: :cascade do |t|
    t.integer  "theme_id",   limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "notice"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "entries", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "body",         limit: 65535
    t.integer  "parent_id",    limit: 4
    t.integer  "np",           limit: 4,     default: 0
    t.integer  "user_id",      limit: 4
    t.boolean  "facilitation",               default: false
    t.boolean  "invisible",                  default: false
    t.boolean  "top_fix",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",     limit: 4
    t.string   "image",        limit: 255
    t.integer  "has_point",    limit: 4
    t.integer  "has_reply",    limit: 4
    t.string   "stamp",        limit: 255
    t.boolean  "agreement"
    t.integer  "claster",      limit: 4
  end

  add_index "entries", ["parent_id"], name: "index_entries_on_parent_id", using: :btree
  add_index "entries", ["updated_at"], name: "index_entries_on_updated_at", using: :btree

  create_table "entry_clasters", force: :cascade do |t|
    t.integer  "entry_id",   limit: 4
    t.integer  "coaster",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exclusions", force: :cascade do |t|
    t.string   "word",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facilitation_infomations", force: :cascade do |t|
    t.text     "body",       limit: 65535
    t.integer  "theme_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facilitation_keywords", force: :cascade do |t|
    t.integer  "theme_id",   limit: 4
    t.string   "word",       limit: 255
    t.float    "score",      limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "theme_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "joins", force: :cascade do |t|
    t.integer  "theme_id",   limit: 4, null: false
    t.integer  "user_id",    limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywords", force: :cascade do |t|
    t.string   "word",       limit: 255
    t.float    "score",      limit: 24
    t.integer  "agree",      limit: 4
    t.integer  "disagree",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",   limit: 4
    t.integer  "user_id",    limit: 4
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "entry_id",    limit: 4
    t.integer  "user_id",     limit: 4
    t.integer  "theme_id",    limit: 4
    t.integer  "activity_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",      limit: 4
    t.integer  "version_id",  limit: 4
  end

  create_table "notices", force: :cascade do |t|
    t.integer  "ntype",            limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "read"
    t.integer  "point_history_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",         limit: 4
    t.integer  "entry_id",         limit: 4
  end

  create_table "phases", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",   limit: 4
    t.integer  "phase_id",   limit: 4
  end

  create_table "point_histories", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "entry_id",    limit: 4
    t.integer  "theme_id",    limit: 4
    t.integer  "activity_id", limit: 4
    t.float    "point",       limit: 24
    t.integer  "atype",       limit: 4
    t.integer  "action",      limit: 4
    t.integer  "depth",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "like_id",     limit: 4
    t.integer  "version_id",  limit: 4
    t.integer  "reply_id",    limit: 4
  end

  create_table "points", force: :cascade do |t|
    t.integer  "theme_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.boolean  "latest"
    t.integer  "entry",      limit: 4
    t.integer  "reply",      limit: 4
    t.integer  "like",       limit: 4
    t.integer  "replied",    limit: 4
    t.integer  "liked",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sum",        limit: 4
  end

  create_table "questions", force: :cascade do |t|
    t.string   "live",          limit: 255
    t.string   "city_name_1",   limit: 255
    t.text     "city_reason_1", limit: 65535
    t.string   "city_name_2",   limit: 255
    t.text     "city_reason_2", limit: 65535
    t.string   "city_name_3",   limit: 255
    t.text     "city_reason_3", limit: 65535
    t.string   "city_name_4",   limit: 255
    t.text     "city_reason_4", limit: 65535
    t.string   "city_name_5",   limit: 255
    t.text     "city_reason_5", limit: 65535
    t.string   "city_name_6",   limit: 255
    t.text     "city_reason_6", limit: 65535
    t.text     "q1",            limit: 65535
    t.text     "q2",            limit: 65535
    t.string   "q3_1",          limit: 255
    t.text     "q3_2",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",       limit: 4
    t.integer  "c1",            limit: 4
    t.integer  "c2",            limit: 4
    t.integer  "c3",            limit: 4
    t.integer  "c4",            limit: 4
    t.integer  "c5",            limit: 4
    t.integer  "c6",            limit: 4
    t.integer  "c7",            limit: 4
    t.integer  "c8",            limit: 4
    t.integer  "c9",            limit: 4
  end

  create_table "tagged_entries", force: :cascade do |t|
    t.integer  "entry_id",   limit: 4, null: false
    t.integer  "issue_id",   limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "themes", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.string   "body",           limit: 255
    t.string   "color",          limit: 255
    t.boolean  "facilitation",                 default: false
    t.boolean  "nolink",                       default: false
    t.boolean  "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "admin_id",       limit: 4
    t.string   "image",          limit: 255
    t.boolean  "point_function",               default: true
    t.text     "body_text",      limit: 65535
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "group_id",       limit: 4
  end

  create_table "thread_classes", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.string   "parent_class", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",     limit: 4
    t.integer  "claster_id",   limit: 4
  end

  create_table "tree_logs", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "theme_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "targer_id",  limit: 4
  end

  create_table "treedata", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "theme_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "out_flag"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "realname",               limit: 255,                null: false
    t.integer  "role",                   limit: 4,     default: 2
    t.string   "name",                   limit: 255,                null: false
    t.integer  "gender",                 limit: 4
    t.integer  "age",                    limit: 4
    t.integer  "home",                   limit: 4,     default: 0
    t.integer  "move",                   limit: 4,     default: 0
    t.integer  "remind",                 limit: 4,     default: 0
    t.integer  "mail_format",            limit: 4,     default: 0
    t.string   "image",                  limit: 255
    t.string   "group",                  limit: 255
    t.text     "body",                   limit: 65535
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vote_entries", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "entry_id",   limit: 4
    t.integer  "point",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",   limit: 4
    t.boolean  "targer"
  end

  create_table "webviews", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "theme_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "webviews", ["theme_id"], name: "index_webviews_on_theme_id", using: :btree
  add_index "webviews", ["user_id"], name: "index_webviews_on_user_id", using: :btree

  create_table "youyakudata", force: :cascade do |t|
    t.integer  "target_id",  limit: 4
    t.integer  "thread_id",  limit: 4
    t.integer  "theme_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body",       limit: 255
  end

  create_table "youyakus", force: :cascade do |t|
    t.string   "body",       limit: 255
    t.integer  "target_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "theme_id",   limit: 4
  end

end
