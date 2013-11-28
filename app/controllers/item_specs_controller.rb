class ItemSpecsController < ApplicationController
	include ApplicationHelper
	require 'will_paginate/array'
	before_filter :find_items
	load_and_authorize_resource 
	
  def index
  	@span = 12
		@show_history = params[:show_history] == "show_history"
		@hide_pending = params[:hide_pending] == "hide_pending"
		@traits = Trait.order(:display_order)
		set_scope
  	if @item
	  	@new_item_spec = ItemSpec.new
			@item_specs = ItemSpec.by_status(@item_id).paginate(:page => params[:page], :per_page => 20)
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
#		@item_spec = ItemSpec.find(params[:id])
		@new_item_spec = @item_spec.dup
		@is_edit_form = true
	end
	
	def create
		if params[:commit] != 'Cancel'		
			@new_item_spec = ItemSpec.new(params[:item_spec])
			@new_item_spec.set_eff_date
			@new_item_spec.set_version
			@new_item_spec.set_editor(current_user.email)
			if @new_item_spec.save!
				flash[:success] = "Item Trait added/changed"
				redirect_to item_specs_path :item_id => params[:item_spec][:item_id]
			else
				redirect_to item_specs_path :item_id => params[:item_spec][:item_id]
			end
		else
			redirect_to item_specs_path :item_id => params[:item_spec][:item_id]
		end
	end

	def destroy
#		@item_spec = ItemSpec.find(params[:id])
		@delete_item_spec = @item_spec.dup
		@delete_item_spec.deleted = true
		@delete_item_spec.set_eff_date
		@delete_item_spec.set_version
		@delete_item_spec.set_editor(current_user.email)
		if @delete_item_spec.save
			flash[:success] = "Item Trait deleted"
			redirect_to item_specs_path :item_id => @item_spec.item_id
		else
			redirect_to item_specs_path :item_id => @item_spec.item_id
		end
	end

	def display
		@span = 12
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
#		@item_spec = ItemSpec.find(params[:id])
		if params[:commit] != 'Cancel'			
			if @item_spec.update_attributes(params[:item_spec])
				flash[:success] = "Notes updated"
			else
				flash[:error] = "Unable to update notes"
			end
		end
		redirect_to item_specs_path :item_id => @item_spec.item_id
  end

	def set_scope
		if params[:item] && !params[:item].blank?
			@item_id = params[:item]	
		elsif params.has_key?(:item_spec)
			@item_id = params[:item_spec][:item_id]
		else
			@item_id = get_item_id
		end

		@item = Item.exists?(@item_id) ? Item.find(@item_id) : nil

		cookies[:item_id] = @item_id	

		@show_history = (params[:show_history] && !params[:show_history].blank?) || (@show_history && !@show_history.blank?)
		@hide_pending = (params[:hide_pending] && !params[:hide_pending].blank?) || (@hide_pending && !@hide_pending.blank?)
	end

	def find_items
		logger.debug 'running find_items'
		@items = Item.where(:deleted => false).order('code').paginate(:page => params[:page], :per_page => 20)
		@index = @items
	end
	
end
