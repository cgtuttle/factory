class ImportRow < ActiveRecord::Base
	belongs_to :import
	has_many :cells, :dependent => :destroy
  attr_accessible :import_error, :import_id, :cells_attributes

	default_scope { where(tenant_id: Tenant.current_id) }

  accepts_nested_attributes_for :cells

end
