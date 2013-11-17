class Item < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id} # validates uniqueness within an account
	has_many :item_specs, dependent: :destroy
	has_many :traits, :through => :item_specs
	attr_accessible :code, :name
	default_scope { where(tenant_id: Tenant.current_id) }

	def self.filtered(filter)
		Item.where('code LIKE ?', filter).order('code') | Item.where('code NOT LIKE ?', filter).order('code')
	end

	def self.by_existence(id)
		@count = Item.count(:all)
		case @count
		when 0
			nil
		when 1
			Item.find(:first)			
		else
			if Item.exists?(id)
				Item.find(id)
			else
				Item.find(:first)				
			end	
		end	
	end

	def self.id_by_existence(id)
		if Item.by_existence(id).blank?
			0
		else
			Item.by_existence(id).id
		end
	end

	def available_traits
		sql_string_used_traits = "
			SELECT a.*
			FROM
				((
				SELECT trait_id, MAX(version) as ver
				FROM item_specs
				WHERE item_id = #{self.id}					
				GROUP BY trait_id) AS y
			INNER JOIN
				(
				SELECT *
				FROM item_specs
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

	def copy_item_specs(copy_item_id)
		item = Item.find(copy_item_id)
		specs = item.item_specs
		specs.each do |s|
			spec = ItemSpec.new(s.attributes.select{ |key, _| ItemSpec.accessible_attributes.include? key})
			spec.item_id = self.id
			spec.version = 1
			spec.eff_date = Date.today	
			spec.save!
		end
	end

	def self.current_id=(id)
		Thread.current[:item_id] = id
	end

	def self.current_id
		Thread.current[:item_id]
	end

end
