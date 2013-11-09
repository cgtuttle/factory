class ChangeRoleIdToInteger < ActiveRecord::Migration
  def up
  	 connection.execute(%q{
    alter table memberships
    alter column role_id
    type integer using cast(role_id as integer)
  })
  end

  def down
  	change_column :memberships, :role_id, :string
  end
end
