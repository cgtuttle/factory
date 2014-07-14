class Item < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id} # validates uniqueness within an account
	has_many :specifications, :dependent => :destroy
	has_many :properties, :through => :specifications
	attr_accessible :code, :name
	default_scope { where(tenant_id: Tenant.current_id) }


	def available_properties
		sql_string_used_properties = "
			SELECT a.*
			FROM
				((
				SELECT property_id, MAX(version) as ver
				FROM specifications
				WHERE item_id = #{self.id}					
				GROUP BY property_id) AS y
			INNER JOIN
				(
				SELECT *
				FROM specifications
				WHERE item_id = #{self.id}
				AND deleted = false) AS z
			ON y.property_id = z.property_id
			AND y.ver = z.version)
			INNER JOIN
				(
				SELECT *
				FROM properties) AS a
			ON a.id = z.property_id
			"

		@used_properties = Property.find_by_sql(sql_string_used_properties)
		if @used_properties.empty?
			Property.all
		else
			Property.where('id NOT IN (?)', @used_properties)
		end
	end

	def copy_specifications(copy_item_id)
		item = Item.find(copy_item_id)
		specs = item.specifications
		specs.each do |s|
			spec = Specification.new(s.attributes.select{ |key, _| Specification.accessible_attributes.include? key})
			spec.item_id = self.id
			spec.version = 1
			spec.eff_date = Date.today	
			spec.save!
		end
	end

end
