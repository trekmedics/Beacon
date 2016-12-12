class CreateRequestForAssistances < ActiveRecord::Migration
  def change
    create_table :request_for_assistances do |t|
      t.references :incident, index: true
      t.references :first_responder, index: true
      t.integer :state, null:false, default: 0
      t.integer :transportation_mode, null:false, default: 0
      t.datetime :eta
      t.timestamps null: false
    end
  end
end
