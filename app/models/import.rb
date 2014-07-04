class Import < ActiveRecord::Base
	has_many :import_rows, :dependent => :destroy
	has_many :cells, :through => :import_rows
	
	accepts_nested_attributes_for :import_rows, :cells

	attr_accessible :model, :first_row, :row_count, :id_column, :import_rows_attributes, :cells_attributes

	default_scope { where(tenant_id: Tenant.current_id) }
	
	require 'csv'
	
	NO_IMPORT = %w[id created_at updated_at deleted deleted_at canceled tenant_id]
	MODELS = %w[Category Item ItemSpec Trait Analysis]
	MODELS_WITH_FK = ["ItemSpec"]
	MODEL_MINIMUM_FIELDS = {:category => "Code", :item => "Code", :item_spec => "Item Code, Trait Code", :trait => "Code", :analysis => "Code"}


end
