class TraitsController < ApplicationController
	include ApplicationHelper
	load_and_authorize_resource
	before_filter :find_traits
	before_filter :find_categories
	
  def index
  	@sortable_url = sort_traits_url
  	@layout_type = "fluid"
		@trait = Trait.new()
		@is_table = true
		@span = 8
	end
	
	def new
		@trait = Trait.new()
	end
	
	def create
		@trait = Trait.new(params[:trait])
		order = (params[:trait][:display_order]).to_i
		@trait.reorder(order)
		if @trait.save
			flash[:success] = "Trait added"
			redirect_to traits_path
		else
			flash[:error] = "Trait could not be added"
			redirect_to traits_path
		end
	end

  def edit
		@trait = Trait.find(params[:id])
		@is_edit_form = true
  end
	
	def update
		@trait = Trait.find(params[:id])
		if @trait.update_attributes(params[:trait])
			flash[:success] = "Trait updated"
			redirect_to traits_path
		else
			render :action => :edit
		end
	end

	def destroy
		if Trait.find(params[:id]).destroy		
			flash[:success] = 'Trait deleted'
			redirect_to traits_path
		end
	end

	def sort
		params[:trait].each_with_index do |id, index|
			Trait.update_all({display_order: index + 1}, {id: id})
		end
		render nothing: true
	end
	
	def find_traits
		@traits = Trait.where(:deleted => false).order("display_order").paginate(:page => params[:page], :per_page => @per_page)
		@index = @traits
	end

	def find_categories
		@categories = Category.order(:display_order)
	end

end
