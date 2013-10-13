class Import < ActiveRecord::Base
	has_many :cells
	
	accepts_nested_attributes_for :cells

	attr_accessible :model, :cells_attributes
	
	require 'csv'
	
	NO_IMPORT = %w[id created_at updated_at deleted deleted_at canceled]
	MODELS = %w[Category Item ItemSpec Spec Analysis]
	MODELS_WITH_FK = ["ItemSpec"]
	MODEL_MINIMUM_FIELDS = {:category => "Code", :item => "Code", :item_spec => "Item Code, Spec Code", :spec => "Code", :analysis => "Code"}


end
