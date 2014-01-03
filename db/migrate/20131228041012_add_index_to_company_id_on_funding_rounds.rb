class AddIndexToCompanyIdOnFundingRounds < ActiveRecord::Migration
  def change
    add_index :funding_rounds, :company_id
    add_index :funding_rounds, :raised_currency_code
    add_index :investments, :investor_id
    add_index :investments, :investor_type
    add_index :investments, :funding_round_id
  end
end
