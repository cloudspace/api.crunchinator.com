class FundedOnFix < ActiveRecord::Migration
  def change
    remove_column :funding_rounds, :funded_year, :string
    remove_column :funding_rounds, :funded_month, :string
    remove_column :funding_rounds, :funded_day, :string

    add_column :funding_rounds, :funded_on, :date
  end
end
