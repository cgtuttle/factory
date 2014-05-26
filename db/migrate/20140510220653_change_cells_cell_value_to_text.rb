class ChangeCellsCellValueToText < ActiveRecord::Migration
  def up
  	change_column :cells, :cell_value, :text
  end

  def down
  	change_column :cells, :cell_value, :string
  end
end
