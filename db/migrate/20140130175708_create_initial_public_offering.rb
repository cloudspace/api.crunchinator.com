class CreateInitialPublicOffering < ActiveRecord::Migration
  def change
    create_table :initial_public_offerings do |t|
      t.integer :company_id
      t.integer :valuation_amount
      t.string :valuation_currency_code
      t.date :offering_on
      t.string :stock_symbol
    end
    add_index :initial_public_offerings, :company_id
  end
end
