class ChangeTwoFieldsInIncident < ActiveRecord::Migration
  def up
    add_column :incidents, :number_of_frs_to_allocate, :integer, default: 3
    add_column :incidents, :number_of_transport_vehicles_to_allocate, :integer, default: 1
    remove_column :incidents, :resource_allocation_fr_fastest_etas, :integer
    remove_column :incidents, :resource_allocation_fr_required_vehicles, :integer
  end
  def down
    remove_column :incidents, :number_of_frs_to_allocate
    remove_column :incidents, :number_of_transport_vehicles_to_allocate
    add_column :incidents, :resource_allocation_fr_fastest_etas, :integer, :integer, default: 3
    add_column :incidents, :resource_allocation_fr_required_vehicles, :integer, :integer, default: 1
  end

end
