class AddFieldsToCompanies < ActiveRecord::Migration
  def change
    change_table :companies do |t|
      t.string :permalink
      t.string :crunchbase_url
      t.string :homepage_url
      t.string :blog_url
      t.string :blog_feed_url
      t.string :twitter_username
      t.string :category_code
      t.integer :number_of_employees
      t.integer :founded_year
      t.integer :founded_month
      t.integer :founded_day
      t.integer :deadpooled_year
      t.integer :deadpooled_month
      t.integer :deadpooled_url
      t.string :tag_list
      t.string :alias_list
      t.string :email_address
      t.string :phone_number
      t.string :description
      t.string :overview
    end
  end
end
