# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_190_921_061_226) do
  create_table 'developers', force: :cascade do |t|
    t.string 'name'
    t.string 'email'
    t.string 'password_digest'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'remember_digest'
    t.index ['email'], name: 'index_developers_on_email', unique: true
  end

  create_table 'movies', force: :cascade do |t|
    t.string 'user_id'
    t.string 'title'
    t.string 'subtitle'
    t.string 'last_owner_comment'
    t.string 'category'
    t.string 'link'
    t.boolean 'is_live'
    t.boolean 'is_recorded'
    t.integer 'comment_count'
    t.string 'large_thumbnail'
    t.string 'small_thumbnail'
    t.string 'country'
    t.integer 'duration'
    t.integer 'created'
    t.boolean 'is_collabo'
    t.boolean 'is_protected'
    t.integer 'max_view_count'
    t.integer 'current_view_count'
    t.integer 'total_view_count'
    t.string 'hls_url'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'timers', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'user_id', null: false
    t.string 'screen_id', null: false
    t.string 'name', null: false
    t.string 'last_cas'
    t.boolean 'is_recordable', default: true
    t.boolean 'is_casting'
    t.integer 'comment_count'
    t.integer 'max_view_count'
    t.integer 'current_view_count'
    t.integer 'total_view_count'
    t.text 'remark'
    t.boolean 'is_compression', default: false
    t.boolean 'is_deleted', default: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end
