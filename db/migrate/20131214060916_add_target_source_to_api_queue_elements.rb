class AddTargetSourceToApiQueueElements < ActiveRecord::Migration
  def change
    add_column :api_queue_elements, :target_source, :string
    add_index :api_queue_elements, :target_source
  end
end
