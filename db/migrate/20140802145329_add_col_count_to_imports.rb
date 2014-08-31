class AddColCountToImports < ActiveRecord::Migration
  def change
    add_column :imports, :col_count, :integer
  end
end
