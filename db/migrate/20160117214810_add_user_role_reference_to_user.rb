class AddUserRoleReferenceToUser < ActiveRecord::Migration
  def change
    add_reference :users, :user_role, index: true
    add_foreign_key :users, :user_roles
  end
end
