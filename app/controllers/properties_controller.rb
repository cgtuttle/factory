class PropertiesController < ApplicationController
	include ApplicationHelper
	load_and_authorize_resource
	before_filter :find_properties
	before_filter :find_categories

	###### CRUD #######
	
	def new
		@property = Property.new()
	end
	
	def create
		@property = Property.new(params[:property])
		order = (params[:property][:display_order]).to_i
		# @property.reorder(order)
		if @property.save
			flash[:success] = "Property added"
			redirect_to properties_path
		else
			flash[:error] = "Property could not be added"
			redirect_to properties_path
		end
	end

  def index
  	@sortable_url = sort_properties_url
  	@layout_type = "fluid"
		@property = Property.new()
		@is_table = true
		@span = 8
	end

	def show
	end

  def edit
		@property = Property.find(params[:id])
		@is_edit_form = true
  end
	
	def update
		@property = Property.find(params[:id])
		if @property.update_attributes(params[:property])
			flash[:success] = "Property updated"
			redirect_to properties_path
		else
			render :action => :edit
		end
	end

	def destroy
		if Property.find(params[:id]).destroy		
			flash[:success] = 'Property deleted'
			redirect_to properties_path
		end
	end

	###### end of CRUD #######

	def bulk_delete
		Property.destroy(params[:deletions])
		redirect_to properties_path
	end

	def sort
		params[:property].each_with_index do |id, index|
			Property.update_all({display_order: index + 1}, {id: id})
		end
		render nothing: true
	end
	
	def find_properties
		@properties = Property.where(:deleted => false).order("display_order").paginate(:page => params[:page], :per_page => @per_page)
		@index = @properties
	end

	def find_categories
		@categories = Category.order(:display_order)
	end

	def import
		Property.import(params[:file])
		redirect_to properties_path
	end

end
