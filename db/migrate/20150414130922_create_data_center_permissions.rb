class CreateDataCenterPermissions < ActiveRecord::Migration
  def change
    create_table :data_center_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :data_center, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
