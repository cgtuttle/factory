class Trait  < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id}
	has_many :item_specs
	has_many :items, :through => :item_specs
	belongs_to :category
	attr_accessible :code, :name, :display_order, :usl, :lsl, :label, :category_id
	default_scope { where(tenant_id: Tenant.current_id) }
	
	def self.filtered(filter)
		Trait.where('code LIKE ?', filter).order('code') | Trait.where('code NOT LIKE ?', filter).order('code')
	end
	
	def reorder(new_order)
		old = self.id ? self.display_order : 0
		old ||= 0
		new_order ||= 0
		if new_order < old
			self.display_order = new_order
			self.save
			Trait.where('display_order >= ? AND display_order <= ? AND id != ?', new_order, old, self.id).update_all("display_order = display_order + 1") 
		elsif new_order > old && old > 0
			self.display_order = new_order
			self.save
			Trait.where('display_order >= ? AND display_order <= ? AND id != ?', old, new_order, self.id).update_all("display_order = display_order - 1")
		elsif old == 0
			traits = Trait.where('display_order >= ?', new_order).update_all("display_order = display_order + 1")
		end
		if Trait.count > 0
			if old != new_order && (old > 0) || Trait.minimum(:display_order) > 1
				i = 1
				traits = Trait.order('display_order')
				traits.each do |s|
					s.display_order = i
					s.save
					i += 1
				end
			end
		end
	end

end

