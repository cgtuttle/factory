module ImportCSV
	require 'csv'

	class CSVFile
		attr_accessor :rows, :columns, :content_rows, :file, :import_id

		def read
			@content_rows = CSV.parse(file.read)
			@rows = content_rows.count
			@columns = content_rows[0].count
		end

		def create_rows
			@import_row_array = []
			content_rows.each_with_index do |row, row_num|
				@import_row_array << "(#{@import.id}, #{row_num	}, #{current_tenant.id})"
			end
			save_to_import_rows(@import_row_array)
		end

	end

	def save_to_import_rows(data_array)
		sql = "INSERT INTO import_rows (import_id, row_id, tenant_id)
			VALUES #{data_array}"
		ActiveRecord::Base.connection.execute(sql)
	end

end