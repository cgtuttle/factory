class AddViewableToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :viewable, :boolean
  end
end
