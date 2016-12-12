class DropFirstResponderIncidentsTable < ActiveRecord::Migration
  def up
    drop_table :first_responder_incidents
  end

  def down
    create_table "first_responder_incidents", force: :cascade do |t|
      t.integer  "first_responder_id"
      t.integer  "incident_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "is_current",         default: true, null: false
      t.datetime "eta"
    end
  end
end
