class CreateUnregisteredParties < ActiveRecord::Migration
  def change
    create_table :unregistered_parties do |t|
      t.string :from
      t.string :to
      t.string :body

      t.timestamps null: false
    end
  end
end
