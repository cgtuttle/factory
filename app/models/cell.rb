class Cell < ActiveRecord::Base
	belongs_to :import

	default_scope { where(tenant_id: Tenant.current_id) }
	
end
