class ImportsController < ApplicationController
	include ApplicationHelper
	include ImportsHelper
	include ImportCSV
	load_and_authorize_resource
		
	def index
	end

	def new
		if params[:model]
			@model = params[:model]
		end
		@is_edit_form = true
	end
	
	def create
		if params[:file]			
			@import = Import.new(params[:import])
			@import.user_id = 0 #current_user.id
			@model = @import.model #selected model
			@import.save
			import_file(params[:file])
			store_csv_cells
			field_choices
			render 'edit'
		else
			redirect_to new_import_path
		end
	end
	
	def update
		@import = Import.find(params[:id])
		@first_row = params[:first_row]
		@row_count = params[:row_count]
		@field_choices = params[:field_choices]
		@field_choices.each_with_index do |name, col_num|						
			update_field_names(@import.id, col_num, name)
			if name.slice!("_id") == "_id" 
				update_id_fields(@import.id, col_num, name.pluralize)
			end			
		end	
		@import.first_row = @first_row
		@import.row_count = @row_count
		if @import.update_attributes(params[:import])
			if save_import
				flash[:success] = "Import completed successfully."
			else
				flash[:error] = "Import not completed"
			end
		end
		redirect_to new_import_path		
	end

	def help
	end
	
end
