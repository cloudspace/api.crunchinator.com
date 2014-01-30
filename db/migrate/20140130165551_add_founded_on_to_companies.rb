class AddFoundedOnToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :founded_on, :date
  end
end
