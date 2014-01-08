class DeadpooledUrlFix < ActiveRecord::Migration
  def change
    change_column :companies, :deadpooled_url, :string
  end
end
