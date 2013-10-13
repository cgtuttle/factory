class AddIndexToMemberships < ActiveRecord::Migration
  def change
  	add_index(:memberships, [:user_id, :tenant_id], unique: true)
  end
end
