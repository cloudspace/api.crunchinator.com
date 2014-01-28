class AddAcquisitions < ActiveRecord::Migration
  def change
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
  end
end
