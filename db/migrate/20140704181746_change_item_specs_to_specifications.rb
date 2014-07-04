class ChangeItemSpecsToSpecifications < ActiveRecord::Migration
  def change
  	rename_table :item_specs, :specifications
  end
end
