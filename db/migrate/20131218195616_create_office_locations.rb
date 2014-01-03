class CreateOfficeLocations < ActiveRecord::Migration
  def change
    create_table :office_locations do |t|
      t.integer :tenant_id
      t.string :tenant_type
      t.boolean :headquarters, default: false
      t.text :description
      t.string :address1
      t.string :address2
      t.string :zip_code
      t.string :city
      t.string :state_code
      t.string :country_code
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
    add_index :office_locations, :tenant_id
    add_index :office_locations, :tenant_type
    add_index :office_locations, :headquarters
    add_index :office_locations, :latitude
    add_index :office_locations, :longitude
  end
end
