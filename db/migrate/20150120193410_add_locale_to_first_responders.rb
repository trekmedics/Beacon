class AddLocaleToFirstResponders < ActiveRecord::Migration
  def change
    add_column :first_responders, :locale, :string
  end
end
