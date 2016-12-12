class AddSidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sid, :string
    add_index :users, :sid, unique: true
  end
end
