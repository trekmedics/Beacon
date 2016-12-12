class AddHospitalToAssistanceRequest < ActiveRecord::Migration
  def up
    add_column :assistance_requests, :hospital_id, :integer
    add_index "assistance_requests", ["hospital_id"], name: "index_assistance_requests_on_hospital_id"
  end
  def down
    remove_column :assistance_requests, :hospital_id, :integer
    remove_index "assistance_requests", ["first_responder_id"]
  end
end
