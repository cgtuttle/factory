class TraitsController < ApplicationController
	load_and_authorize_resource
	before_filter :find_traits
	before_filter :find_categories
	
  def index
  	@layout_type = "fluid"
		@trait = Trait.new()
		@is_table = true
		@span = 8
	end
	
	def new
		@trait = Trait.new()
	end
	
	def create
		if params[:commit] != 'Cancel'
			@trait = Trait.new(params[:trait])
			order = (params[:trait][:display_order]).to_i
			@trait.reorder(order)
			if @trait.save
				flash[:success] = "Trait added"
				redirect_to traits_path
			else
				flash[:error] = "Trait could not be added"
#TODO Add more descriptive error messages
				redirect_to traits_path
			end
		else
			redirect_to traits_path
		end
	end

  def edit
		@trait = Trait.find(params[:id])
		@is_edit_form = true
  end
	
	def update
		if params[:commit] != 'Cancel'
			@trait = Trait.find(params[:id])
			order = (params[:trait][:display_order]).to_i
			order = 0 if order.nil?
			@trait.reorder(order)
			if @trait.update_attributes(params[:trait])
				flash[:success] = "Trait updated"
				redirect_to traits_path
			else
				redirect_to traits_path
			end
		else
			redirect_to traits_path
		end
	end
	
	def find_traits
		@traits = Trait.where(:deleted => false).order("display_order").paginate(:page => params[:page], :per_page => 20)
		@index = @traits
	end

	def find_categories
		@categories = Category.order(:display_order)
	end

end
