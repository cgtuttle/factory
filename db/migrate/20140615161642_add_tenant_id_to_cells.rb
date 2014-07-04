class AddTenantIdToCells < ActiveRecord::Migration
  def change
    add_column :cells, :tenant_id, :integer
  end
end
