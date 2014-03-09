class Trait  < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id}
	has_many :item_specs
	has_many :items, :through => :item_specs
	belongs_to :category
	attr_accessible :code, :name, :display_order, :usl, :lsl, :label, :category_id
	accepts_nested_attributes_for :category
	default_scope { where(tenant_id: Tenant.current_id) }
	
end

