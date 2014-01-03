class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :api_queue_elements, :target_source, :data_source
  end
end
