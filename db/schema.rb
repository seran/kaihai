# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_26_114405) do
  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "tagline"
    t.datetime "updated_at", null: false
  end

  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "entry_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["entry_id"], name: "index_bookmarks_on_entry_id"
    t.index ["user_id", "entry_id"], name: "index_bookmarks_on_user_id_and_entry_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.integer "entry_id", null: false
    t.integer "likes_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["entry_id", "created_at"], name: "index_comments_on_entry_id_and_created_at"
    t.index ["entry_id"], name: "index_comments_on_entry_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "entries", force: :cascade do |t|
    t.integer "author_id", null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "entryable_id", null: false
    t.string "entryable_type", null: false
    t.integer "likes_count", default: 0, null: false
    t.integer "space_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_entries_on_author_id"
    t.index ["entryable_type", "entryable_id"], name: "index_entries_on_entryable_type_and_entryable_id", unique: true
    t.index ["space_id", "created_at"], name: "index_entries_on_space_id_and_created_at"
    t.index ["space_id"], name: "index_entries_on_space_id"
  end

  create_table "event_responses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.integer "response", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["event_id", "user_id"], name: "index_event_responses_on_event_id_and_user_id", unique: true
    t.index ["event_id"], name: "index_event_responses_on_event_id"
    t.index ["user_id"], name: "index_event_responses_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "location"
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["starts_at"], name: "index_events_on_starts_at"
  end

  create_table "favorites", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "space_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["space_id"], name: "index_favorites_on_space_id"
    t.index ["user_id", "space_id"], name: "index_favorites_on_user_id_and_space_id", unique: true
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "likeable_id", null: false
    t.string "likeable_type", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
    t.index ["user_id", "likeable_type", "likeable_id"], name: "index_likes_on_user_id_and_likeable_type_and_likeable_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "actor_id"
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.integer "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "read_at"
    t.integer "recipient_id"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["recipient_id", "created_at"], name: "index_notifications_on_recipient_id_and_created_at"
    t.index ["recipient_id", "read_at"], name: "index_notifications_on_recipient_id_and_read_at"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "poll_answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "poll_id", null: false
    t.integer "poll_option_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["poll_id"], name: "index_poll_answers_on_poll_id"
    t.index ["poll_option_id"], name: "index_poll_answers_on_poll_option_id"
    t.index ["user_id", "poll_id"], name: "index_poll_answers_on_user_id_and_poll_id", unique: true
    t.index ["user_id"], name: "index_poll_answers_on_user_id"
  end

  create_table "poll_options", force: :cascade do |t|
    t.string "body", null: false
    t.datetime "created_at", null: false
    t.integer "poll_id", null: false
    t.datetime "updated_at", null: false
    t.index ["poll_id"], name: "index_poll_options_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.text "question", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "space_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["space_id", "user_id", "status"], name: "index_requests_on_space_id_and_user_id_and_status"
    t.index ["space_id"], name: "index_requests_on_space_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "spaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id"
    t.text "description"
    t.string "handle", null: false
    t.integer "members_count", default: 0, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0, null: false
    t.index ["creator_id"], name: "index_spaces_on_creator_id"
    t.index ["handle"], name: "index_spaces_on_handle", unique: true
    t.index ["visibility"], name: "index_spaces_on_visibility"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "role", default: 0, null: false
    t.integer "space_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["space_id", "user_id"], name: "index_subscriptions_on_space_id_and_user_id", unique: true
    t.index ["space_id"], name: "index_subscriptions_on_space_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "accent", default: "blue", null: false
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "handle"
    t.datetime "invited_at"
    t.integer "invited_by_id"
    t.string "name"
    t.string "password_digest"
    t.integer "role", default: 0
    t.integer "status", default: 0, null: false
    t.string "theme", default: "warm-light", null: false
    t.string "time_zone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
  end

  create_table "waves", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "from_user_id", null: false
    t.integer "space_id", null: false
    t.integer "to_user_id", null: false
    t.datetime "updated_at", null: false
    t.index ["from_user_id", "to_user_id", "space_id"], name: "index_waves_on_from_user_id_and_to_user_id_and_space_id", unique: true
    t.index ["from_user_id"], name: "index_waves_on_from_user_id"
    t.index ["space_id"], name: "index_waves_on_space_id"
    t.index ["to_user_id"], name: "index_waves_on_to_user_id"
  end

  add_foreign_key "bookmarks", "entries"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "comments", "entries"
  add_foreign_key "comments", "users"
  add_foreign_key "entries", "spaces"
  add_foreign_key "entries", "users", column: "author_id"
  add_foreign_key "event_responses", "events"
  add_foreign_key "event_responses", "users"
  add_foreign_key "favorites", "spaces"
  add_foreign_key "favorites", "users"
  add_foreign_key "likes", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "poll_answers", "poll_options"
  add_foreign_key "poll_answers", "polls"
  add_foreign_key "poll_answers", "users"
  add_foreign_key "poll_options", "polls"
  add_foreign_key "requests", "spaces"
  add_foreign_key "requests", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "spaces", "users", column: "creator_id"
  add_foreign_key "subscriptions", "spaces"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "users", "users", column: "invited_by_id"
  add_foreign_key "waves", "spaces"
  add_foreign_key "waves", "users", column: "from_user_id"
  add_foreign_key "waves", "users", column: "to_user_id"

  # Virtual tables defined in this database.
  # Note that virtual tables may not work with other database engines. Be careful if changing database.
  create_virtual_table "entry_search", "fts5", ["body", "tokenize=porter"]
end
