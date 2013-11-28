class CategoriesController < ApplicationController
	load_and_authorize_resource
	
	def index
		@categories = Category.order('display_order').paginate(:page => params[:page], :per_page => 30)
		@index = @categories
		@category = Category.new
		@span = 6
		@is_table = true
	end
	
	def create
		if params[:commit] != 'Cancel'
			@category = Category.new(params[:category])
			order = (params[:category][:display_order]).to_i
			@category.reorder(order)
			if @category.save
				flash[:success] = "Category added"
				redirect_to categories_path
			end
		else
			redirect_to categories_path
		end
	end

  def edit
		@is_edit_form = true
	end
	
	def update
		if params[:commit] != 'Cancel'
			@category = Category.find(params[:id])
			order = (params[:category][:display_order]).to_i
			@category.reorder(order)
			if @category.update_attributes(params[:category])
				flash[:success] = 'Category updated'
			end
		else
			flash[:success] = 'Update canceled'
		end
		redirect_to categories_path
	end

	def destroy
		if Category.find(params[:id]).destroy		
			flash[:success] = 'Category deleted'
			redirect_to categories_path
		end
	end

end
