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

ActiveRecord::Schema.define(version: 20140130205747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "acquisitions", force: true do |t|
    t.string  "price_amount"
    t.string  "price_currency_code"
    t.string  "term_code"
    t.string  "source_url"
    t.string  "source_description"
    t.date    "acquired_on"
    t.integer "acquiring_company_id"
    t.integer "acquired_company_id"
  end

  add_index "acquisitions", ["acquired_company_id"], name: "index_acquisitions_on_acquired_company_id", using: :btree
  add_index "acquisitions", ["acquiring_company_id"], name: "index_acquisitions_on_acquiring_company_id", using: :btree

  create_table "api_queue_elements", force: true do |t|
    t.integer  "num_runs",        default: 0
    t.boolean  "processing",      default: false
    t.boolean  "complete",        default: false
    t.datetime "last_attempt_at"
    t.string   "permalink"
    t.text     "error"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_source"
    t.string   "namespace"
  end

  add_index "api_queue_elements", ["complete"], name: "index_api_queue_elements_on_complete", using: :btree
  add_index "api_queue_elements", ["data_source"], name: "index_api_queue_elements_on_data_source", using: :btree
  add_index "api_queue_elements", ["last_attempt_at"], name: "index_api_queue_elements_on_last_attempt_at", using: :btree
  add_index "api_queue_elements", ["namespace"], name: "index_api_queue_elements_on_namespace", using: :btree
  add_index "api_queue_elements", ["num_runs"], name: "index_api_queue_elements_on_num_runs", using: :btree
  add_index "api_queue_elements", ["permalink"], name: "index_api_queue_elements_on_permalink", unique: true, using: :btree
  add_index "api_queue_elements", ["processing"], name: "index_api_queue_elements_on_processing", using: :btree

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
    t.string   "deadpooled_url"
    t.string   "tag_list"
    t.string   "alias_list"
    t.string   "email_address"
    t.string   "phone_number"
    t.string   "description"
    t.text     "overview"
    t.integer  "category_id"
    t.date     "deadpooled_on"
  end

  add_index "companies", ["category_id"], name: "index_companies_on_category_id", using: :btree

  create_table "financial_organizations", force: true do |t|
    t.string   "name"
    t.string   "permalink"
    t.string   "crunchbase_url"
    t.string   "blog_url"
    t.string   "blog_feed_url"
    t.string   "twitter_username"
    t.string   "phone_number"
    t.string   "email_address"
    t.text     "description"
    t.integer  "number_of_employees"
    t.date     "founded_date"
    t.text     "overview"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "financial_organizations", ["permalink"], name: "index_financial_organizations_on_permalink", unique: true, using: :btree

  create_table "funding_rounds", force: true do |t|
    t.string   "round_code"
    t.string   "source_url"
    t.string   "source_description"
    t.decimal  "raw_raised_amount"
    t.string   "raised_currency_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "crunchbase_id"
    t.date     "funded_on"
  end

  add_index "funding_rounds", ["company_id"], name: "index_funding_rounds_on_company_id", using: :btree
  add_index "funding_rounds", ["crunchbase_id"], name: "index_funding_rounds_on_crunchbase_id", unique: true, using: :btree
  add_index "funding_rounds", ["raised_currency_code"], name: "index_funding_rounds_on_raised_currency_code", using: :btree

  create_table "initial_public_offerings", force: true do |t|
    t.integer "company_id"
    t.integer "valuation_amount",        limit: 8
    t.string  "valuation_currency_code"
    t.date    "offering_on"
    t.string  "stock_symbol"
  end

  add_index "initial_public_offerings", ["company_id"], name: "index_initial_public_offerings_on_company_id", using: :btree

  create_table "investments", force: true do |t|
    t.integer  "investor_id"
    t.string   "investor_type"
    t.integer  "funding_round_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "investments", ["funding_round_id"], name: "index_investments_on_funding_round_id", using: :btree
  add_index "investments", ["investor_id"], name: "index_investments_on_investor_id", using: :btree
  add_index "investments", ["investor_type"], name: "index_investments_on_investor_type", using: :btree

  create_table "office_locations", force: true do |t|
    t.integer  "tenant_id"
    t.string   "tenant_type"
    t.boolean  "headquarters", default: false
    t.text     "description"
    t.string   "address1"
    t.string   "address2"
    t.string   "zip_code"
    t.string   "city"
    t.string   "state_code"
    t.string   "country_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "office_locations", ["headquarters"], name: "index_office_locations_on_headquarters", using: :btree
  add_index "office_locations", ["latitude"], name: "index_office_locations_on_latitude", using: :btree
  add_index "office_locations", ["longitude"], name: "index_office_locations_on_longitude", using: :btree
  add_index "office_locations", ["tenant_id"], name: "index_office_locations_on_tenant_id", using: :btree
  add_index "office_locations", ["tenant_type"], name: "index_office_locations_on_tenant_type", using: :btree

  create_table "people", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  add_index "people", ["permalink"], name: "index_people_on_permalink", using: :btree

  create_table "zip_code_geos", force: true do |t|
    t.string   "zip_code"
    t.string   "city"
    t.string   "state"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zip_code_geos", ["zip_code"], name: "index_zip_code_geos_on_zip_code", using: :btree

end
