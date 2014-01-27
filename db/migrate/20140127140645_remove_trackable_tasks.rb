class RemoveTrackableTasks < ActiveRecord::Migration
  def change
    drop_table :trackable_tasks_task_runs
  end
end
