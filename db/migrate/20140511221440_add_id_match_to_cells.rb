class AddIdMatchToCells < ActiveRecord::Migration
  def change
    add_column :cells, :id_match, :boolean
  end
end
