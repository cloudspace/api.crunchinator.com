class CreateInvestors < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.references :investor, polymorphic: true
      t.integer :funding_round_id
      t.timestamps
    end
  end
end
