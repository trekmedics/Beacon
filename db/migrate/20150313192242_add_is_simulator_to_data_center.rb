class AddIsSimulatorToDataCenter < ActiveRecord::Migration
  def change
    add_column :data_centers, :is_simulator, :boolean, null: false, default: false
  end
end
