class AddResourcesNeededToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :resource_allocation_fr_fastest_etas, :integer
    add_column :incidents, :resource_allocation_fr_required_vehicles, :integer
  end
end
