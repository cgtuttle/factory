class ItemsController < ApplicationController
	include ApplicationHelper
	require 'will_paginate/array'
	before_filter :find_items
	before_filter :set_fluid
	load_and_authorize_resource 

	###### CRUD #######

  def index
  	logger.debug "running items.index: @current_tenant = #{@current_tenant.inspect}"
		@new_item = Item.new	
		@properties = Property.all
		@is_table = true
  end

  def edit
		@item = Item.find(params[:id])
		@is_edit_form = true
  end

  def update
		@item = Item.find(params[:id])
		@history = params[:history]
		@future = params[:future]
		if @item.update_attributes(params[:item])
			flash[:success] = "Item updated"
		else
			flash[:error] = "Unable to update item"
		end
		redirect_to items_path
  end

  def new
		@item = Item.new
  end

  def create
		@item = Item.new(params[:item])
		if @item.save
			flash[:success] = "Item added"
			cookies[:item_id] = @item.id
			if params[:include_specs]
				@item.copy_specifications(params[:copy_item_id])
				redirect_to specifications_path
			else
				redirect_to items_path
			end
		else
			flash[:error] = "Item could not be added"
			redirect_to items_path
		end
	end

  def destroy
		Item.find(params[:id]).destroy
		flash[:success] = "Item deleted"
		redirect_to items_path
  end

	###### end of CRUD #######

	def bulk_delete
		Item.destroy(params[:deletions])
		redirect_to items_path
	end

	def copy
		@copy_item = Item.find(params[:id])
		@new_item = Item.new()
		@new_item.name = @copy_item.name
		@new_item.code = @copy_item.code
		@new_item.tenant_id = @copy_item.tenant_id
		@is_edit_form = true
	end
	
	def find_items
		@items = Item.where(:deleted => false).order('code').paginate(:page => params[:page], :per_page => @per_page)
		@index = @items
	end

	def set_fluid
		@fixed = false
	end

end
