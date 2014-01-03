class CreateZipCodeGeos < ActiveRecord::Migration
  def change
    create_table :zip_code_geos do |t|
      t.string :zip_code
      t.string :city
      t.string :state
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
    add_index :zip_code_geos, :zip_code
  end
end
