class AddCommentFieldToIncidents < ActiveRecord::Migration
  def change
    add_column :incidents, :comment, :text
  end
end
