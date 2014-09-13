class Property  < ActiveRecord::Base
	validates :code, :presence => true, :uniqueness => {:scope => :tenant_id}
	validate :category_id_has_match
	has_many :specifications, :dependent => :destroy
	has_many :items, :through => :specifications
	belongs_to :category
	attr_accessible :code, :name, :display_order, :usl, :lsl, :label, :category_id
	accepts_nested_attributes_for :category
	default_scope { where(tenant_id: Tenant.current_id) }

	def self.import(file)
		CSV.foreach(file.path, headers: true) do |row|
			row['category_id'] = Category.where('code = (?)', row['category_id']).pluck(:id).first
			Property.create! row.to_hash
		end
	end

	private

	def category_id_has_match
		self.category_id && Category.exists?(self.category_id) || self.category_id.blank?
	end
	
end

