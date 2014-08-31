module ImportsHelper

	def field_choices
		@obj = @model.constantize
		@field_choices = Array.new
		@obj.columns.each do |c|
			unless Import::NO_IMPORT.include?(c.name)
				@field_choices << [c.name.humanize.pluralize, c.name]
			end
		end
	end

end
