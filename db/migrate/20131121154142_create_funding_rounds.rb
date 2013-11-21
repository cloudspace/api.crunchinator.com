class CreateFundingRounds < ActiveRecord::Migration
  def change
    create_table :funding_rounds do |t|
      t.string :round_code
      t.string :source_url
      t.string :source_description
      t.decimal :raised_amount
      t.string :raised_currency_code
      t.integer :funded_year
      t.integer :funded_month
      t.integer :funded_day

      t.timestamps
    end
  end
end
