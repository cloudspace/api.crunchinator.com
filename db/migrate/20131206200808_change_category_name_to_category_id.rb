class ChangeCategoryNameToCategoryId < ActiveRecord::Migration
  def change
    remove_column :companies, :category_code
    add_column :companies, :category_id, :integer
    add_index :companies, :category_id
  end
end
