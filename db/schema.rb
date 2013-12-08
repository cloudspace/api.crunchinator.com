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

ActiveRecord::Schema.define(version: 20131206200808) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "companies", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.string   "crunchbase_url"
    t.string   "homepage_url"
    t.string   "blog_url"
    t.string   "blog_feed_url"
    t.string   "twitter_username"
    t.integer  "number_of_employees"
    t.integer  "founded_year"
    t.integer  "founded_month"
    t.integer  "founded_day"
    t.integer  "deadpooled_year"
    t.integer  "deadpooled_month"
    t.integer  "deadpooled_url"
    t.string   "tag_list"
    t.string   "alias_list"
    t.string   "email_address"
    t.string   "phone_number"
    t.string   "description"
    t.text     "overview"
    t.string   "deadpooled_day"
    t.integer  "category_id"
  end

  add_index "companies", ["category_id"], name: "index_companies_on_category_id", using: :btree

  create_table "funding_rounds", force: true do |t|
    t.string   "round_code"
    t.string   "source_url"
    t.string   "source_description"
    t.decimal  "raw_raised_amount"
    t.string   "raised_currency_code"
    t.integer  "funded_year"
    t.integer  "funded_month"
    t.integer  "funded_day"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "crunchbase_id"
  end

  add_index "funding_rounds", ["crunchbase_id"], name: "index_funding_rounds_on_crunchbase_id", unique: true, using: :btree

  create_table "investments", force: true do |t|
    t.integer  "investor_id"
    t.string   "investor_type"
    t.integer  "funding_round_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  add_index "people", ["permalink"], name: "index_people_on_permalink", using: :btree

  create_table "trackable_tasks_task_runs", force: true do |t|
    t.string   "task_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "error_text"
    t.text     "log_text"
    t.boolean  "success",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
