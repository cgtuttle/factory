class Specification < ActiveRecord::Base
	belongs_to :item
	belongs_to :property
	belongs_to :analysis
	delegate :category, :to => :property

	validates :item_id, :property_id, :presence => true
	validate :valid_eff_date?
	attr_accessible :property_id, :string_value, :text_value, :numeric_value, :usl, \
		:lsl, :unit_of_measure, :analysis_id, :eff_date, :item_id, :version, :tag, \
		:document_title, :document_url, :document_version, :deleted, :canceled, :notes

	before_save :default_values

	scope :active, where(:canceled => false, :deleted => false)

	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			item_code = row['item_id']
			row['item_id'] = Item.where('code = (?)', item_code).pluck(:id).first			
			property_code = row['property_id']
			row['property_id'] = Property.where('code = (?)', property_code).pluck(:id).first
			if !Specification.create row.to_hash
				logger.info "Error creating row #{row.inspect}"
			end
		end
	end

	def self.visible_by_item(item, visibility)
		stats = self.includes(:property => :category).where(:item_id => item)
			.order("categories.display_order, properties.display_order, eff_date DESC, version DESC")
		stats.select{|s| s if s.status == (visibility & s.status)}
	end

	def self.visible_by_property(property, visibility)
		stats = self.includes(:item).where(:property_id => property)
			.order("items.code, eff_date DESC, version DESC")
		stats.select{|s| s if s.status == (visibility & s.status)}
	end

	def status
		current_spec = Specification
			.where(["item_id = ? AND property_id = ? AND eff_date <= ? ", self.item_id, self.property_id, Date.today] )
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
		unless Specification.where(:item_id => self.item_id, :property_id => self.property_id).empty?
			Specification.where(:item_id => self.item_id, :property_id => self.property_id).order('version DESC').first.version
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
		if self.eff_date.blank?
			self.eff_date = Date.today
		elsif self.eff_date < Date.today
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

