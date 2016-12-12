class RemoveDefaultValuesForFieldsOnIncidents < ActiveRecord::Migration
  def up
    change_column_default :incidents, :number_of_frs_to_allocate, nil
    change_column_default :incidents, :number_of_transport_vehicles_to_allocate, nil
  end

  def down
    change_column_default :incidents, :number_of_frs_to_allocate, 3
    change_column_default :incidents, :number_of_transport_vehicles_to_allocate, 1
  end
end
