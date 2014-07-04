module ImportCSV
	require 'csv'


#=======================================================

	class CSVCell
		attr_accessor :row, :column, :value, :field_name
	end

#=======================================================

	class CSVFile
		attr_accessor :rows, :columns, :content, :file

		def parse
			@content = CSV.parse(file.read)
			@rows = @content.count
			@columns = @content[0].count
		end

		def columns
			@columns
		end

		def content
			@content
		end

		def rows
			@rows
		end
	end

#=======================================================	
#=======================================================

	def import_file(file_spec)
		if file_spec
			@rows = []
			@row_nums = []
			csv_file = CSVFile.new	
			csv_file.file = file_spec	
			csv_file.parse
			@parsed_file = csv_file.content

			#-----------------Row Level block-----------------------------
			@parsed_file.each_with_index do |row, row_num|				
				@row = []

				#---------------Cell level block----------------------------
				row.each_with_index do |value, col_num|					
					@cell = CSVCell.new
					@cell.row = row
					encoded_value = value.blank? ? "" : value.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, replace: "") # Clean out illegal characters
					@cell.value = ActiveRecord::Base.connection.quote(encoded_value) # delimit values
					@row << "#{@cell.value}, #{row_num}, #{col_num}, #{@import.id}, #{Tenant.current_id}"
				end
				#-----------------------------------------------------------
	
				@rows << "(#{@row.join("), (")})"
				@row_nums << "(#{@import.id}, #{row_num	}, #{Tenant.current_id})"
			end
			#-------------------------------------------------------------

			@csv_file = @rows.join(", ")
			@row_num_array = "#{@row_nums.join(", ")}"
			@row_count = csv_file.rows
			@column_count = csv_file.columns
		end
	end

#=======================================================

	def load_import_array(import_id)
		@import = Import.find(import_id)
		@import_array = Cell.joins(import_row: :import) \
			.where("imports.id = ? AND (import_error = (?) OR import_error IS ?) AND cells.field_name != ''", @import.id, false, nil) \
			.order("row_num", "col_num")
	end

#=======================================================

	def save_import # Move the cell data to the actual table
		@obj = @import.model.constantize
		load_import_array(@import.id)
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
																						logger.debug "save_array =  #{save_array.join ", "}"						#
																						et = Time.now - start                                           #
																						logger.debug "Start = #{start}, End = #{Time.now}, ET = #{et}"  #
		#-------------------------------------------------------------------------------------------------------#
		
	end

#=======================================================

	def store_csv_rows # Add row to import_rows table
		sql = "INSERT INTO import_rows (import_id, row_id, tenant_id)
			VALUES #{@row_num_array}"
		ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def store_csv_cells # Load cells table
		sql = "INSERT INTO cells (import_value, row_num, col_num, import_id, tenant_id) 
			VALUES #{@csv_file}"
		ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def update_cells_import_row_id # Find the import_row.id for the foriegn key in cells
		sql = "UPDATE cells
			SET import_row_id = import_rows.id
			FROM import_rows 
			WHERE import_rows.import_id = #{@import.id}
			AND cells.import_id = import_rows.import_id
			AND cells.row_num = import_rows.row_id"
		ActiveRecord::Base.connection.execute(sql)
	end		

#=======================================================

	def update_field_names(field_name) # Add field names to cells
		Cell.where("col_num = ? AND import_id = ?", @col_num, @import.id).update_all("field_name = '#{field_name}'")

		# sql = "UPDATE cells SET field_name = '#{field_name}' 
		# 	WHERE col_num = #{@col_num} 
		# 	AND import_id = #{@import.id}"
		# ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def update_id_fields(table_name) # Convert code to id in cells for a given column
		sql = "UPDATE cells SET id_value = #{table_name}.id,
			id_match = TRUE,
			field_value =  #{table_name}.id
			FROM #{table_name}
			WHERE cells.col_num = #{@col_num} 
			AND cells.import_id = #{@import.id} 
			AND cells.import_value = #{table_name}.code			 
			AND #{table_name}.tenant_id = #{Tenant.current_id}"
		ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def set_row_match_error
		ImportRow.joins(:cells).where("(cells.id_match IS ? 
		 		OR cells.id_match = ? 
		 		OR cells.field_name = ?) 
			AND import_rows.import_id = ? 
		 	AND cells.col_num = ? 
		 	AND cells.import_id = ?",
		 	nil, false, '', @import.id, @col_num, @import.id).update_all(import_error: true)


		# sql = "UPDATE import_rows SET import_error = TRUE
		# 	FROM cells
		# 	WHERE (cells.id_match IS NULL 
		# 		OR cells.id_match = FALSE
		# 		OR cells.field_name = '')
		# 	AND import_rows.import_id = #{@import.id}
		# 	AND import_rows.row_id = cells.row_num
		# 	AND cells.col_num = #{@col_num} 
		# 	AND cells.import_id = #{@import.id}"
		# ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def update_field_values # Move non-id import values to field value
		Cell.joins(:import_row).where("(cells.id_match IS ? 
					OR cells.id_match = ?) 
				AND (import_error IS ? 
					OR import_error = ?) 
				AND import_rows.import_id = ?",
				nil, false, nil, false, @import.id).update_all("field_value = import_value")

		# sql = "UPDATE cells SET field_value = import_value
		# 	FROM import_rows
		# 	WHERE (cells.id_match IS NULL OR cells.id_match = FALSE)
		# 	AND (import_rows.import_error IS NULL OR import_rows.import_error = FALSE)
		# 	AND import_rows.import_id = #{import_id}
		# 	AND import_rows.row_id = cells.row_num"
		# ActiveRecord::Base.connection.execute(sql)
	end

end