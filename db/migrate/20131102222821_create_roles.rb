class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
    	t.string :role_name
    	t.integer :display_order

      t.timestamps
    end
  end
end
