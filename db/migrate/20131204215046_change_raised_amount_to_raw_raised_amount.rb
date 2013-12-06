class ChangeRaisedAmountToRawRaisedAmount < ActiveRecord::Migration
  def self.up
    rename_column :funding_rounds, :raised_amount, :raw_raised_amount
  end

  def self.down
    rename_column :funding_rounds, :raw_raised_amount, :raised_amount
  end
end
