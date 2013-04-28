class DropSubdomainFromTenant < ActiveRecord::Migration
  def up
  	remove_column :tenants, :subdomain
  end

  def down
  	add_column :tenants, :subdomain, :string
  end
end
