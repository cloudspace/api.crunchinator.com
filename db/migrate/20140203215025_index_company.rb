class IndexCompany < ActiveRecord::Migration
  def change
    add_index :companies, :name
    add_index :companies, :permalink
  end
end
