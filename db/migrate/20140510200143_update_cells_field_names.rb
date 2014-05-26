class UpdateCellsFieldNames < ActiveRecord::Migration
  def up
  	change_table :cells do |t|
  		t.rename :row, :row_num
  		t.rename :column, :col_num
  	end
  end

  def down
  	change_table :cells do |t|
  		t.rename :row_num, :row
  		t.rename :col_num, :column
  	end

  end
end
