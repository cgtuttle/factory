class Import < ActiveRecord::Base
	attr_accessible :model, :first_row, :row_count, :col_count, :id_column, :import_rows_attributes, :cells_attributes, :tenant_id
	default_scope { where(tenant_id: Tenant.current_id) }
	
	require 'csv'
	
	NO_IMPORT = %w[id created_at updated_at deleted deleted_at canceled tenant_id]
	MODELS = %w[Category Item Specification Property Analysis]
	MODELS_WITH_FK = ["Specification"]
	MODEL_MINIMUM_FIELDS = {:category => "Code", :item => "Code", :specification => "Item Code, Property Code", :property => "Code", :analysis => "Code"}


end
