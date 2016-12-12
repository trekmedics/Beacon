class AddSubcategoryRefIncidents < ActiveRecord::Migration
  def change
    add_reference :incidents, :subcategory, index: true
    add_foreign_key :incidents, :subcategories
  end
end
