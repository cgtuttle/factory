class ChangeTraitIdToProperyId < ActiveRecord::Migration
  def change
  	rename_column :specifications, :trait_id, :property_id
  end
end
