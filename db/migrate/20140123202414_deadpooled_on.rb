class DeadpooledOn < ActiveRecord::Migration
  def change
    remove_column :companies, :deadpooled_year, :string
    remove_column :companies, :deadpooled_month, :string
    remove_column :companies, :deadpooled_day, :string
    add_column :companies, :deadpooled_on, :date
  end
end
