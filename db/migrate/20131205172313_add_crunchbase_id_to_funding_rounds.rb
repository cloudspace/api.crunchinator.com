class AddCrunchbaseIdToFundingRounds < ActiveRecord::Migration
  def change
    add_column :funding_rounds, :crunchbase_id, :integer
    add_index :funding_rounds, :crunchbase_id, :unique => true
  end
end
