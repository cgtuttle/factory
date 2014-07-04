class AddFieldsToCells < ActiveRecord::Migration
  def change
  	add_column :cells, :import_value, :string
  	add_column :cells, :id_value, :integer
  end
end
