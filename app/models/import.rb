class Import < ActiveRecord::Base
	has_many :cells
	
	accepts_nested_attributes_for :cells

	attr_accessible :model, :first_row, :row_count, :col_count, :id_column, :import_rows_attributes, :cells_attributes, :tenant_id
  attr_accessor :rows, :file

	default_scope { where(tenant_id: Tenant.current_id) }
	
	require 'csv'
	
	NO_IMPORT = %w[id created_at updated_at deleted deleted_at canceled tenant_id]
	MODELS = %w[Category Item Specification Property Analysis]
	MODELS_WITH_FK = ["Specification"]
	MODEL_MINIMUM_FIELDS = {:category => "Code", :item => "Code", :specification => "Item Code, Property Code", :property => "Code", :analysis => "Code"}

	def read
		@rows = CSV.parse(file.read) # ok
		self.row_count = @rows.count
		self.col_count = @rows[0].count
		self.save
	end

	def fill_cells_array
		cells_array = []	
		@rows.each_with_index do |row, row_num|		
			row.each_with_index do |value, col_num|
				row_array = []
				encoded_value = value.blank? ? "" : value.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, replace: "") # Clean out illegal characters
				escaped_value = ActiveRecord::Base.connection.quote(encoded_value) # delimit values
				row_array << "#{escaped_value}, #{row_num}, #{col_num}, #{tenant_id}, #{id}"
				cells_array << "(#{row_array.join("), (")})"
			end
		end
		data_string = "#{cells_array.join(", ")}"
		save_to_cells(data_string)
	end

	def save_to_cells(data_string)
		Rails.logger.level = 1
		sql = "INSERT INTO cells (import_value, row_num, col_num, tenant_id, import_id) 
			VALUES #{data_string}"
		Cell.connection.execute(sql)
		Rails.logger.level = 0
	end

	def update_field_names(field_name) # Add field names to cells
		logger.info "Running update_field_names()"
		Cell.where("col_num = ? AND import_id = ?", @col_num, self.id).update_all("field_name = '#{field_name}'")
	end

	def update_id_fields(table_name, col_num) # Convert code to id in cells for a given column
		logger.info "Running update_id_fields()"
		Rails.logger.level = 1
		sql = "UPDATE cells SET id_value = #{table_name}.id,
			id_match = TRUE,
			field_value =  #{table_name}.id
			FROM #{table_name}
			WHERE cells.col_num = #{col_num} 
			AND cells.import_id = #{self.id} 
			AND cells.import_value = #{table_name}.code			 
			AND #{table_name}.tenant_id = #{Tenant.current_id}"
		ActiveRecord::Base.connection.execute(sql)
		Rails.logger.level = 0
		save_row_match_errors(col_num)
		set_row_errors
logger.debug "@row_errors = #{@row_errors.inspect}"
	end

	def save_row_match_errors(col_num)
		logger.info "Running save_row_match_errors()"
		Cell.where("(id_match IS ? 
		 		OR id_match = ? 
		 		OR field_name = ?) 
		 	AND cells.col_num = ?",
		 	nil, false, '', col_num).update_all(:had_save_error => true, :save_error_text => "No row id match")
	end

	def set_row_errors
		logger.info "Running save_row_errors()"
		@row_errors = Cell.where(:had_save_error => true).select(:row_num).uniq
	end

	def update_field_values # Move non-id import values to field value
		logger.info "Running update_field_values()"
		Cell.where("cells.id_match IS ? 
					OR cells.id = ? ",
				nil, self.id).update_all("field_value = import_value")
	end

	def save_import # Move the cell data to the actual table
		@obj = self.model.constantize
		load_import_array
		columns = 0
		#------------Determine number of columns
		@import_array.each do |row_cell|
			if columns < row_cell.col_num
				columns = row_cell.col_num
			end
		end
		#---------------------------------------
		cell_hash = {}
		field_names = []
		save_array = []		
																						start = Time.now
		@import_array.each do |row_cell|
			if row_cell.row_num > @first_row.to_i			
				field_name = row_cell.field_name.to_sym
				cell_hash[field_name] = row_cell.field_value
				#--------Full row loaded, save it
				if row_cell.col_num == columns
					save_object = @obj.new(cell_hash)
					save_object.save!
					cell_hash = {}				
				end
				#---------------------------------
			end			
		end

		#-------------------------------------------------------------------------------------------------------#
		#																				logger.debug "save_array =  #{save_array.join ", "}"						#
																						et = Time.now - start                                           #
																						logger.debug "Start = #{start}, End = #{Time.now}, ET = #{et}"  #
		#-------------------------------------------------------------------------------------------------------#
		
	end

	def load_import_array
		@import_array = Cell \
			.where("import_id = (?) AND row_num NOT IN (?) AND cells.field_name != ''", self.id, @row_errors) \
			.order("row_num", "col_num")
	end

	def test
		self.first_row = 10
		self.save
	end

end
