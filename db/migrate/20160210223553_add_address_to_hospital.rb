class AddAddressToHospital < ActiveRecord::Migration
  def change
    add_column :hospitals, :address, :string, default: '', null: false
  end
end
