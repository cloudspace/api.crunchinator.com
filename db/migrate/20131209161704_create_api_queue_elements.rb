class CreateApiQueueElements < ActiveRecord::Migration
  def change
    create_table :api_queue_elements do |t|
      t.integer :num_runs, :default => 0
      t.boolean :processing, :default => false
      t.boolean :complete, :default => false
      t.datetime :last_attempt_at
      t.string :permalink
      t.text :error

      t.timestamps
    end
    add_index :api_queue_elements, :num_runs
    add_index :api_queue_elements, :processing
    add_index :api_queue_elements, :complete
    add_index :api_queue_elements, :last_attempt_at
    add_index :api_queue_elements, :permalink, :unique => true
  end
end
