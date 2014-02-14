class ConsolidateMigrations < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :permalink
      t.string :crunchbase_url
      t.string :homepage_url
      t.string :blog_url
      t.string :blog_feed_url
      t.string :twitter_username
      t.integer :category_id
      t.integer :number_of_employees
      t.integer :founded_year
      t.integer :founded_month
      t.integer :founded_day
      t.date :founded_on
      t.date :deadpooled_on
      t.string :deadpooled_url
      t.string :tag_list
      t.string :alias_list
      t.string :email_address
      t.string :phone_number
      t.string :description
      t.text :overview

      t.timestamps
    end
    add_index :companies, :category_id
    add_index :companies, :name
    add_index :companies, :permalink, unique: true

    create_table :people do |t|
      t.string :firstname
      t.string :lastname
      t.string :permalink

      t.timestamps
    end
    add_index :people, :permalink, :length => 10, unique: true

    create_table :funding_rounds do |t|
      t.string :round_code
      t.string :source_url
      t.string :source_description
      t.decimal :raw_raised_amount
      t.string :raised_currency_code
      t.date :funded_on
      t.integer :company_id
      t.integer :crunchbase_id

      t.timestamps
    end
    add_index :funding_rounds, :crunchbase_id, :unique => true
    add_index :funding_rounds, :company_id
    add_index :funding_rounds, :raised_currency_code

    create_table :investments do |t|
      t.references :investor, polymorphic: true
      t.integer :funding_round_id
      t.timestamps
    end
    add_index :investments, :investor_id
    add_index :investments, :investor_type
    add_index :investments, :funding_round_id

    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
    add_index :categories, :name, :unique => true

    create_table :api_queue_elements do |t|
      t.integer :num_runs, :default => 0
      t.boolean :processing, :default => false
      t.boolean :complete, :default => false
      t.datetime :last_attempt_at
      t.string :permalink
      t.string :data_source
      t.text :error
      t.string :namespace

      t.timestamps
    end
    add_index :api_queue_elements, :num_runs
    add_index :api_queue_elements, :processing
    add_index :api_queue_elements, :complete
    add_index :api_queue_elements, :last_attempt_at
    add_index :api_queue_elements, :permalink, :unique => true
    add_index :api_queue_elements, :namespace
    add_index :api_queue_elements, :data_source

    create_table :financial_organizations do |t|
      t.string :name
      t.string :permalink
      t.string :crunchbase_url
      t.string :blog_url
      t.string :blog_feed_url
      t.string :twitter_username
      t.string :phone_number
      t.string :email_address
      t.text :description
      t.integer :number_of_employees
      t.date :founded_date
      t.text :overview
      t.timestamps
    end
    add_index :financial_organizations, :permalink, unique: true

    create_table :office_locations do |t|
      t.integer :tenant_id
      t.string :tenant_type
      t.boolean :headquarters, default: false
      t.text :description
      t.string :address1
      t.string :address2
      t.string :zip_code
      t.string :city
      t.string :state_code
      t.string :country_code
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
    add_index :office_locations, :tenant_id
    add_index :office_locations, :tenant_type
    add_index :office_locations, :headquarters
    add_index :office_locations, :latitude
    add_index :office_locations, :longitude

    create_table :zip_code_geos do |t|
      t.string :zip_code
      t.string :city
      t.string :state
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
    add_index :zip_code_geos, :zip_code, unique: true

    create_table :acquisitions do |t|
      t.string :price_amount
      t.string :price_currency_code
      t.string :term_code
      t.string :source_url
      t.string :source_description
      t.date :acquired_on
      t.integer :acquiring_company_id
      t.integer :acquired_company_id
    end
    add_index :acquisitions, :acquiring_company_id
    add_index :acquisitions, :acquired_company_id
    add_index :acquisitions, :price_amount
    add_index :acquisitions, :price_currency_code

    create_table :initial_public_offerings do |t|
      t.integer :company_id
      t.column :valuation_amount, :bigint
      t.string :valuation_currency_code
      t.date :offering_on
      t.string :stock_symbol
    end
    add_index :initial_public_offerings, :company_id
    add_index :initial_public_offerings, :valuation_amount
    add_index :initial_public_offerings, :valuation_currency_code
  end
end
