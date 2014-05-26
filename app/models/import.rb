class Import < ActiveRecord::Base
	has_many :cells
	
	accepts_nested_attributes_for :cells

	attr_accessible :model, :first_row, :row_count, :id_column, :cells_attributes

	default_scope { where(tenant_id: Tenant.current_id) }
	
	require 'csv'
	
	NO_IMPORT = %w[id created_at updated_at deleted deleted_at canceled tenant_id]
	MODELS = %w[Category Item ItemSpec Trait Analysis]
	MODELS_WITH_FK = ["ItemSpec"]
	MODEL_MINIMUM_FIELDS = {:category => "Code", :item => "Code", :item_spec => "Item Code, Trait Code", :trait => "Code", :analysis => "Code"}


end
