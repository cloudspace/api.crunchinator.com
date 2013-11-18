class AddPermalinkToPerson < ActiveRecord::Migration
  def change
    change_table :people do |t|
      t.column :permalink, :string
      add_index :people, :permalink, :length => 10
    end
  end
end
