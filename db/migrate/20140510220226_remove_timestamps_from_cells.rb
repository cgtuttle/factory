class RemoveTimestampsFromCells < ActiveRecord::Migration
  def up
    remove_column :cells, :created_at
    remove_column :cells, :updated_at
    remove_column :cells, :saved_at
  end

  def down
    add_column :cells, :saved_at, :string
    add_column :cells, :updated_at, :string
    add_column :cells, :created_at, :string
  end
end
