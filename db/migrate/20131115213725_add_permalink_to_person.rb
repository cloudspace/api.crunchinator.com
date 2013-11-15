class AddPermalinkToPerson < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.string :permalink
      add_index :permalink, :length => 10
    end
  end
end
