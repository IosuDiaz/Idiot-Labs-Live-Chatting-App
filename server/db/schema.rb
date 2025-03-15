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

ActiveRecord::Schema[7.2].define(version: 2025_03_14_222120) do
  create_table "channels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: true
    t.index ["creator_id"], name: "index_channels_on_creator_id"
    t.index ["name"], name: "index_channels_on_name", unique: true
  end

  create_table "memberships", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "channel_id", null: false
    t.integer "role", default: 0
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_memberships_on_channel_id"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id", "channel_id"], name: "index_memberships_on_user_and_channel", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "sender_id", null: false
    t.bigint "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["sender_id", "channel_id"], name: "index_messages_on_sender_and_channel"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "nickname", limit: 20, null: false
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

  add_foreign_key "channels", "users", column: "creator_id"
  add_foreign_key "memberships", "channels"
  add_foreign_key "memberships", "users"
  add_foreign_key "messages", "channels"
  add_foreign_key "messages", "users", column: "sender_id"
end
