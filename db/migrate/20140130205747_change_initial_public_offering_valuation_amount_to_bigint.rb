class ChangeInitialPublicOfferingValuationAmountToBigint < ActiveRecord::Migration
  def self.up
    change_column :initial_public_offerings, :valuation_amount, :bigint
  end

  def self.down
   change_column :initial_public_offerings, :valuation_amount, :int
  end
end
