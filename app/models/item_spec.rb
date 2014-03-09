class ItemSpec < ActiveRecord::Base
	belongs_to :item
	belongs_to :trait
	belongs_to :analysis
	delegate :category, :to => :trait

	validates :item_id, :trait_id, :presence => true
	validate :valid_eff_date?
	attr_accessible :trait_id, :string_value, :text_value, :numeric_value, :usl, \
		:lsl, :unit_of_measure, :analysis_id, :eff_date, :item_id, :version, :tag, \
		:document_title, :document_url, :document_version, :deleted, :canceled, :notes

	before_save :default_values

	scope :active, where(:canceled => false, :deleted => false)

	def self.visible_by_item(item, visibility)
		stats = self.includes(:trait => :category).where(:item_id => item)
			.order("categories.display_order, traits.display_order, eff_date DESC, version DESC")
		stats.select{|s| s if s.status == (visibility & s.status)}
	end

	def self.visible_by_trait(trait, visibility)
		stats = self.includes(:item).where(:trait_id => trait)
			.order("items.code, eff_date DESC, version DESC")
		stats.select{|s| s if s.status == (visibility & s.status)}
	end

	def status
		current_spec = ItemSpec
			.where(["item_id = ? AND trait_id = ? AND eff_date <= ? ", self.item_id, self.trait_id, Date.today] )
			.order('eff_date DESC, version DESC').first
		status = ((self.deleted || self.canceled) ? 8 : 16)
		
		if current_spec		
			current_date = current_spec.eff_date
			current_version = current_spec.version

			if (self.eff_date > Date.today)
				status += 4 #pending
			elsif (self.eff_date == current_date and self.version < current_version) or self.eff_date < current_date
				status += 1 #past
			else
				status += 2 #current
			end			
		end
		
	end

	def set_version
		self.version = ((self.last_version.nil? && 0) || self.last_version) + 1
	end
	
	def last_version
		unless ItemSpec.where(:item_id => self.item_id, :trait_id => self.trait_id).empty?
			ItemSpec.where(:item_id => self.item_id, :trait_id => self.trait_id).order('version DESC').first.version
		end
	end
	
	def set_eff_date
		if !self.eff_date
			self.eff_date = Date.today
		end
	end

	def set_editor(user)
		self.changed_by = user
	end

	def default_values
		self.eff_date ||= Date.today
		self.string_value ||= ""
		self.text_value ||= ""
	end

	def valid_eff_date?
		if self.eff_date < Date.today
			errors.add(:eff_date, 'must be today or later')
		end
	end

	def eff_status
		s = self.status
		if 8 == s & 8
			"deleted"
		elsif 1 == s & 1
			"past"
		elsif 2 == s & 2
			"current"
		elsif 4 == s & 4
			"pending"
		end
	end

end

