class MisnamedFieldInFinancialOrganizations < ActiveRecord::Migration
  def change
    rename_column :financial_organizations, :crunhbase_url, :crunchbase_url
  end
  
  
end
