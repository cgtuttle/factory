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

	def load_import_array(import_id)
		@import = Import.find(import_id)
		@import_array = Cell.where("import_id = ? AND field_name != ?", import_id, '').order("row_num", "col_num")
	end

#=======================================================

	def save_import
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
			field_name = row_cell.field_name.to_sym
			cell_hash[field_name] = row_cell.cell_value
			#--------Full row loaded, save it
			if row_cell.col_num == columns
				save_object = @obj.where('code = (?)', cell_hash[code]) || @obj.new(cell_hash)
#				save_object = @obj.new(cell_hash)				
				save_object.save!
				cell_hash = {}				
			end
			#---------------------------------
		end
																						logger.debug "save_array =  #{save_array.join ", "}"
																						et = Time.now - start
																						logger.debug "Start = #{start}, End = #{Time.now}, ET = #{et}"
	end

#=======================================================

	def import_file(file_spec)
		if file_spec
			@rows = []
			csv_file = CSVFile.new	
			csv_file.file = file_spec	
			csv_file.parse
			@parsed_file = csv_file.content
			@parsed_file.each_with_index do |row, row_num|				
				@row = []				
				row.each_with_index do |value, col_num|					
					@cell = CSVCell.new
					@cell.row = row
					encoded_value = value.blank? ? "" : value.encode('UTF-8', 'binary', :invalid => :replace, :undef => :replace, replace: "")
					@cell.value = ActiveRecord::Base.connection.quote(encoded_value) # Clean out illegal characters
					@row << "#{@cell.value}, #{row_num}, #{col_num}, #{@import.id}"
				end				
				@rows << "(#{@row.join("), (")})"	
			end
			@csv_file = @rows.join(", ")
			@row_count = csv_file.rows
			@column_count = csv_file.columns
		end
	end

#=======================================================

	def store_csv_cells # Load cells table
		sql = "INSERT INTO cells (cell_value, row_num, col_num, import_id) 
			VALUES #{@csv_file}"
		ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def update_field_names(import_id, col_num, field_name) # Add field names to cells
		sql = "UPDATE cells SET field_name = '#{field_name}' 
			WHERE col_num = #{col_num} 
			AND import_id = #{import_id}"
		ActiveRecord::Base.connection.execute(sql)
	end

#=======================================================

	def update_id_fields(import_id, col_num, table_name) # Convert code to id in cells for a given column
		sql = "UPDATE cells SET id_match = false
			WHERE cells.col_num = #{col_num} 
			AND cells.import_id = #{import_id}"
		ActiveRecord::Base.connection.execute(sql)	
		sql = "UPDATE cells SET cell_value = #{table_name}.id, 
			id_match = true  
			FROM #{table_name} 
			WHERE cells.col_num = #{col_num} 
			AND cells.import_id = #{import_id} 
			AND cells.cell_value = #{table_name}.code"
		ActiveRecord::Base.connection.execute(sql)			
	end
	
#=======================================================
	# def copy
	# 	conn = ActiveRecord::Base.connection
	# 	rc = conn.raw_connection
	# 	rc.exec("COPY cells (import_id, row, col, cell_value, field_name) FROM STDIN WITH CSV")
	# 	# Setup raw connection
	# 	file = File.open('largefile.txt', 'r')
	# 	while !file.eof?
	# 		row_array = file.readline
	# 	  # Add row to copy data
	# 	  rc.put_copy_data(file.readline)
	# 	end
	# 	# We are done adding copy data
	# 	rc.put_copy_end
	# 	# Display any error messages
	# 	while res = rc.get_result
	# 	  if e_message = res.error_message
	# 	    p e_message
	# 	  end
	# 	end
	# end
#=======================================================
end