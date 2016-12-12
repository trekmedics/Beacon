class CreateWhiteListedPhoneNumbers < ActiveRecord::Migration
  def change
    create_table :white_listed_phone_numbers do |t|
      t.references :data_center, index: true, foreign_key: true
      t.string :phone_number
      t.string :name
      t.timestamps null: false
    end
  end
end
