class AddRowIdToImportRows < ActiveRecord::Migration
  def change
    add_column :import_rows, :row_id, :integer
  end
end
