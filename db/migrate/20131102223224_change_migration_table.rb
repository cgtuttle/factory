class ChangeMigrationTable < ActiveRecord::Migration
  def change	
  	rename_column :memberships, :role, :role_id  	
  end

  
end
