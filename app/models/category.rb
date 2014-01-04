class Category < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id}
	has_many :traits, :dependent => :nullify

  attr_accessible :code, :name, :display_order

	default_scope { where(tenant_id: Tenant.current_id) }
	
	def reorder(new_order)
		old = self.display_order ? self.display_order : 0
		if new_order < old
			self.display_order = new_order
			self.save
			Category.where('display_order >= ? AND display_order <= ? AND id != ?', new_order, old, self.id).update_all("display_order = display_order + 1") 
		elsif new_order > old && old > 0
			self.display_order = new_order
			self.save
			Category.where('display_order >= ? AND display_order <= ? AND id != ?', old, new_order, self.id).update_all("display_order = display_order - 1")
		elsif old == 0
			Category.where('display_order >= ?', new_order).update_all("display_order = display_order + 1")
		end
		if old != new_order && old > 0
			i = 1
			categories = Category.order('display_order')
			categories.each do |c|
				c.display_order = i
				c.save
				i += 1
			end
		end
	end
	
end
