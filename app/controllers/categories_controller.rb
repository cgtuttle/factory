class CategoriesController < ApplicationController
	load_and_authorize_resource

	###### CRUD #######
	
	def index
		@categories = Category.order('display_order').paginate(:page => params[:page], :per_page => @per_page)
		@sortable_url = sort_categories_url
		@index = @categories
		@category = Category.new
		@span = 6
		@is_table = true
	end
	
	def create
		@category = Category.new(params[:category])
		if @category.save
			flash[:success] = "Category added"
			redirect_to categories_path
		else
			render :new
		end
	end

  def edit
		@is_edit_form = true
	end
	
	def update
		@is_edit_form = true
		@category = Category.find(params[:id])
		if @category.update_attributes(params[:category])
			flash[:success] = "Category updated"
			redirect_to categories_path				
		else
			render :edit
		end
	end

	def destroy
		if Category.find(params[:id]).destroy		
			flash[:success] = 'Category deleted'
			redirect_to categories_path
		end
	end

	###### end of CRUD #######

	def bulk_delete
	Category.destroy(params[:deletions])
		redirect_to categories_path
	end	

	def sort
		params[:category].each_with_index do |id, index|
			Category.update_all({display_order: index + 1}, {id: id})
		end
		render nothing: true
	end

end
