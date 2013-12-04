class CreateTrackableTaskTables < ActiveRecord::Migration
  def self.up
    create_table :trackable_tasks_task_runs do |t|
      t.string :task_type
      t.datetime :start_time
      t.datetime :end_time
      t.text :error_text, :limit => 1073741823 
      t.text :log_text, :limit => 1073741823
      t.boolean :success, :default => false

      t.timestamps
    end 
  end

  def self.down
    drop_table :trackable_tasks_task_runs
  end
end
