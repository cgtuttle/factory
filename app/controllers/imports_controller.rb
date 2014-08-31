class ImportsController < ApplicationController
	require 'benchmark'
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
	
	def create # choose import file and load it into @csv_file
		if params[:file]					
			Cell.delete_all
			@import = Import.new(params[:import])
			@import.user_id = 0 # current_user.id
			@model = @import.model # selected model			
			@import.save
			@import.file = params[:file]
			@import.read
			@import.fill_cells_array
			@col_count = @import.col_count
			@row_count = @import.row_count
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
		count = 0
		@field_choices.each_with_index do |name, col_num|				
			count += 1 unless name == ""
			@file_col_count = col_num				
			@import.update_field_names(name)
			if name.slice!("_id") == "_id" 
				@import.update_id_fields(name.pluralize, col_num)
			end		
		end
		@import.update_field_values	
		@import.first_row = @first_row
		@import.col_count = count
		@import.row_count = @row_count
		@import.save
		if @import.update_attributes(params[:import])
			if @import.save_import
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
