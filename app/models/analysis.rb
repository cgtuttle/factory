class Analysis < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id}
	has_many :item_specs

	attr_accessible :code, :name, :instructions

	default_scope { where(tenant_id: Tenant.current_id) }	

end
