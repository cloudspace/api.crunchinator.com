class AddNamespaceToApiQueueElement < ActiveRecord::Migration
  def change
    add_column :api_queue_elements, :namespace, :string
    add_index :api_queue_elements, :namespace
  end
end
