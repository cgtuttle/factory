class AddImportRowIdToCells < ActiveRecord::Migration
  def change
    add_column :cells, :import_row_id, :integer
  end
end
