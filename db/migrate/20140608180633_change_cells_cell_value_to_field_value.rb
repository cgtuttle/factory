class ChangeCellsCellValueToFieldValue < ActiveRecord::Migration
  def change
  	rename_column :cells, :cell_value, :field_value
  end
end
