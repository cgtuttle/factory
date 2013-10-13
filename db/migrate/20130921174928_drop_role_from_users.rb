class DropRoleFromUsers < ActiveRecord::Migration
  change_table :users do |t|
  	t.remove :role
  end
end
