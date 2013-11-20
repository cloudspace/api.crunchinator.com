class AddDeadpooledDayToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :deadpooled_day, :string
  end
end
