class ConvertStringToTextForCompanies < ActiveRecord::Migration
  def change
    change_column :companies, :overview, :text
  end
end
