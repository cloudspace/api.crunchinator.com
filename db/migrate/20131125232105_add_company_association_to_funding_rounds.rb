class AddCompanyAssociationToFundingRounds < ActiveRecord::Migration
  def change
    add_column :funding_rounds, :company_id, :integer
  end
end
