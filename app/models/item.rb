class Item < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id} # validates uniqueness within an account
	has_many :specifications, dependent: :destroy
	has_many :traits, :through => :specifications
	attr_accessible :code, :name
	default_scope { where(tenant_id: Tenant.current_id) }


	def available_traits
		sql_string_used_traits = "
			SELECT a.*
			FROM
				((
				SELECT trait_id, MAX(version) as ver
				FROM specifications
				WHERE item_id = #{self.id}					
				GROUP BY trait_id) AS y
			INNER JOIN
				(
				SELECT *
				FROM specifications
				WHERE item_id = #{self.id}
				AND deleted = false) AS z
			ON y.trait_id = z.trait_id
			AND y.ver = z.version)
			INNER JOIN
				(
				SELECT *
				FROM traits) AS a
			ON a.id = z.trait_id
			"

		@used_traits = Trait.find_by_sql(sql_string_used_traits)
		if @used_traits.empty?
			Trait.all
		else
			Trait.where('id NOT IN (?)', @used_traits)
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
