class AddTenantIdToImportRows < ActiveRecord::Migration
  def change
    add_column :import_rows, :tenant_id, :integer
  end
end
