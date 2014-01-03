class AddFieldsToFinancialOrganization < ActiveRecord::Migration
  def change    
    create_table :financial_organizations do |t|
      t.string :name
      t.string :permalink
      t.string :crunhbase_url
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
  end
end
