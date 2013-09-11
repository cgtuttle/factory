class Import < ActiveRecord::Base
	has_many :cells
	
	accepts_nested_attributes_for :cells
	
	require 'csv'
	
	NO_IMPORT = %w[id created_at updated_at deleted deleted_at canceled]
	MODELS = %w[Category Item ItemSpec Spec analysis]
	MODELS_WITH_FK = ["ItemSpec"]

	

end
