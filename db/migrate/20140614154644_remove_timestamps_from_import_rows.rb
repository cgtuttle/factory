class RemoveTimestampsFromImportRows < ActiveRecord::Migration
  def up
    remove_column :import_rows, :created_at
    remove_column :import_rows, :updated_at
  end

  def down
    add_column :import_rows, :updated_at, :string
    add_column :import_rows, :created_at, :string
  end
end
