class CreateRowNumIndexInCells < ActiveRecord::Migration
  def change
  	add_index :cells, :row_num
  end
end
