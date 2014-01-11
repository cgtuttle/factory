class Category < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id}
	has_many :traits, :dependent => :nullify

  attr_accessible :code, :name, :display_order

	default_scope { where(tenant_id: Tenant.current_id) }
	
end
