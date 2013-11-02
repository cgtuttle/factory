class RemoveDeletedFromCategories < ActiveRecord::Migration
  def up
  	remove_column :categories, :deleted
  	remove_column :categories, :deleted_at
  end

  def down
  	add_column :categories, :deleted, :boolean
  	add_column :categories, :deleted_at, :datetime
  end

end
