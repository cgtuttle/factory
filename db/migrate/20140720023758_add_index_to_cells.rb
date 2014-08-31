class AddIndexToCells < ActiveRecord::Migration
  def change
  	add_index :cells, :import_id 
  	add_index :cells, :import_row_id
  	add_index :cells, :tenant_id
  	add_index :import_rows, :import_id
  	add_index :import_rows, :tenant_id
  	add_index :import_rows, :row_id, :unique => true
  end
end
