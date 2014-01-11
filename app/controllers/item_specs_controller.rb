class ItemSpecsController < ApplicationController
	include ApplicationHelper
	require 'will_paginate/array'
	before_filter :find_items
	before_filter :initialize_status_checkboxes
	load_and_authorize_resource 
	
  def new
  	set_scope
  	@current_traits = ItemSpec.where(:item_id => @item.id).pluck(:trait_id)
  	@available_traits = Trait.where('id not in (?)', @current_traits )
  	@new_item_spec = ItemSpec.new
  end

  def index
  	@span = 12

  	if !params.has_key?(:item_spec)
  		# cookies & params are "1" or "0", @variables are true or false
			params[:show_history] = cookies[:history] == "1" ? "1" : nil
	  	params[:show_pending] = cookies[:pending] == "1" ? "1" : nil
	  	params[:show_deleted] = cookies[:deleted] == "1" ? "1" : nil
	  end
	  
  	@history = params[:show_history] == "1"
  	@pending = params[:show_pending] == "1"
  	@deleted = params[:show_deleted] == "1"

  	cookies[:history] = @history ? "1" : "0"
  	cookies[:pending] = @pending ? "1" : "0"
  	cookies[:deleted] = @deleted ? "1" : "0"

		@visibility = (@history ? 1 : 0) + (@pending ? 4 : 0) + (@deleted ? 8 : 0) + 18
		@traits = Trait.order(:display_order)
		set_scope
  	if @item
	  	@new_item_spec = ItemSpec.new
			@item_specs = ItemSpec.visible(@item_id, @visibility).paginate(:page => params[:page], :per_page => 15) #main ItemSpec retrieval

			@index = @item_specs
			@items = Item.order(:code)
			@available_traits = Trait.all
			@span = 12
			@is_table = true
		else
			flash[:alert] = "There are no items yet - please add at least one"
			redirect_to items_path
		end
  end

	def edit
		@new_item_spec = @item_spec.dup
		@new_item_spec.eff_date = Date.today
		@is_edit_form = true
	end
	
	def create
		@new_item_spec = ItemSpec.new(params[:item_spec])
		@new_item_spec.set_eff_date
		@new_item_spec.set_version
		@new_item_spec.set_editor(current_user.email)
		if @new_item_spec.save!
			flash[:success] = "Item Trait added/changed"
			redirect_to item_specs_path :item_id => params[:item_spec][:item_id]
		else
			render :new
		end
	end

	def destroy
		@delete_item_spec = @item_spec.dup
		@delete_item_spec.deleted = true
		@delete_item_spec.eff_date = Date.today
		@delete_item_spec.set_version
		@delete_item_spec.set_editor(current_user.email)
		if @delete_item_spec.save!
			flash[:success] = "Item Trait deleted"
			redirect_to item_specs_path :item_id => @item_spec.item_id
		else
			flash[:alert] = "Could not delete Item Trait"
			redirect_to item_specs_path :item_id => @item_spec.item_id
		end
	end

	def display
		@span = 12
		@items = Item.order('code')
		@display = true
		@body_class = "display"	
		if params.has_key?(:item)
			@item = Item.find(params[:item][:id])
		elsif params.has_key?(:item_id)
			@item = Item.by_existence(params[:item_id])		
		else
			@item = Item.find(get_item_id)
		end
		if @item
			cookies[:item_id] = @item.id
			@item_specs = ItemSpec.includes(:trait => :category).where(:item_id => @item).order("categories.display_order")
			@categories = @item_specs.group_by{|is| is.trait.category}		
		end
	end	

	def copy
		@item_spec = ItemSpec.find(params[:id])
	end

	def cancel
		@item_spec = ItemSpec.find(params[:id])
		@item_spec.canceled = true
		@item_spec.set_eff_date
		@item_spec.set_version
		if @item_spec.save
			flash[:success] = "Future Item Trait canceled"
			redirect_to item_specs_path :item_id => @item_spec.item_id
		else
			redirect_to item_specs_path :item_id => @item_spec.item_id
		end
	end

	def notes
		@item_spec = ItemSpec.find(params[:id])
		@is_edit_form = true
	end
	
	def update
		if @item_spec.update_attributes(params[:item_spec])
			flash[:success] = "Notes updated"
			redirect_to item_specs_path :item_id => @item_spec.item_id
		else
			render :notes
		end
  end

	def set_scope
		if params[:item] && !params[:item].blank?
			@item_id = params[:item]	
		elsif params.has_key?(:item_spec)
			@item_id = params[:item_spec][:item_id]
		elsif params.has_key?(:item_id)
			@item_id = params[:item_id]
		else
			@item_id = get_item_id
		end

		@item = Item.exists?(@item_id) ? Item.find(@item_id) : nil

		cookies[:item_id] = @item_id
	end

	def find_items
		@items = Item.where(:deleted => false).order('code').paginate(:page => params[:page], :per_page => @per_page)
		@index = @items
	end

	def initialize_status_checkboxes
		cookies[:history] ||= "0"
		cookies[:pending] ||= "1"
		cookies[:deleted] ||= "0"
	end
	
end
