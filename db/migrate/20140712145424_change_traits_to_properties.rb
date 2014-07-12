class ChangeTraitsToProperties < ActiveRecord::Migration
  def change
  	rename_table :traits, :properties  	
  end
end
