class ItemSpecsController < ApplicationController
	include ApplicationHelper
	require 'will_paginate/array'
	before_filter :initialize_status_checkboxes, :find_items, :find_traits
	load_and_authorize_resource 

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

	def copy
		@item_spec = ItemSpec.find(params[:id])		
		@items = Item.where("id NOT IN (?)", @item_spec.item_id).order(:code)
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
			@item_id = params[:item][:id]
			@item = Item.exists?(@item_id) ? Item.find(@item_id) : nil
		end	
		set_current_item
		if @item
			cookies[:item_id] = @item.id
			@item_specs = ItemSpec.includes(:trait => :category).where(:item_id => @item).order("categories.display_order")
			@categories = @item_specs.group_by{|is| is.trait.category}		
		end
	end

	def edit
		@new_item_spec = @item_spec.dup
		@new_item_spec.eff_date = Date.today
		@is_edit_form = true
	end

  def index
  	@span = 12  	
		@is_table = true
  	set_list_view
  	set_visibility
  	
		@traits = Trait.order(:display_order)
		@available_traits = Trait.all
		@available_items = Item.all

		if @list_for_an_item
			if params.has_key?(:item_spec)
				@item_id = params[:item_spec][:item_id]
				@item = Item.exists?(@item_id) ? Item.find(@item_id) : nil
			end
			set_current_item
	  	if @item
		  	@new_item_spec = ItemSpec.new
				@item_specs = ItemSpec.visible_by_item(@item.id, @visibility).paginate(:page => params[:page], :per_page => 15) #main ItemSpec retrieval
				@index = @item_specs
				@items = Item.order(:code)				
			else
				flash[:alert] = "No items exist. Please add at least one."
				redirect_to items_path
			end
		else # @list_for_a_trait
			if params.has_key?(:item_spec)
				@trait_id = params[:item_spec][:trait_id]
				@trait = Trait.exists?(@trait_id) ? Trait.find(@trait_id) : nil
			end
			set_current_trait
			if @trait
				@new_item_spec = ItemSpec.new
				@item_specs = ItemSpec.visible_by_trait(@trait.id, @visibility).paginate(:page => params[:page], :per_page => 15) #main ItemSpec retrieval
				@index = @item_specs
				@current_traits = ItemSpec.where(:item_id => @item.id).pluck(:trait_id)
				@traits = Trait.where('id IN (?)', @current_traits).order(:code)				
			end
		end
  end
	
  def new
  	set_item_scope
  	if @item
	  	@current_traits = ItemSpec.where(:item_id => @item.id).pluck(:trait_id)
	  	@available_traits = Trait.where('id not in (?)', @current_traits )
	  	@new_item_spec = ItemSpec.new
	  end
  end

	def notes
		@item_spec = ItemSpec.find(params[:id])
		@is_edit_form = true
	end

  def paste
		@item_spec = ItemSpec.find(params[:id])
		@item_list = params[:copy_to][:items]
		@set_eff_date = params[:eff_date][:copy] != '1'
		ttl = 0
		success = 0
		@item_list.each do |i|
			@new_item_spec = @item_spec.dup
			@item = Item.where("code = ?", i).first
			@new_item_spec.item_id = @item.id
			@new_item_spec.eff_date = Date.today if @set_eff_date
			if @new_item_spec.save
				ttl += 1
				success += 1
			else
				ttl += 1
			end
		end		
		flash[:success] = "#{@item_spec.trait.code} copied to #{success} of #{ttl} items"
		redirect_to item_specs_path :item_id => @item_spec.item_id
	end

	def update
		if @item_spec.update_attributes(params[:item_spec])
			flash[:success] = "Notes updated"
			redirect_to item_specs_path :item_id => @item_spec.item_id
		else
			render :notes
		end
  end

# Utilities
	
	def find_items
		@items = Item.where(:deleted => false).order('code')
		@index = @items
	end

	def find_traits
		@traits = Trait.where(:deleted => false).order('code')
		@index = @traits
	end

	def initialize_status_checkboxes
		cookies[:history] ||= "0"
		cookies[:pending] ||= "1"
		cookies[:deleted] ||= "0"
	end

	def set_item_scope
		if params[:item] && !params[:item].blank?
			@item_id = params[:item]	
		elsif params.has_key?(:item_spec)
			@item_id = params[:item_spec][:item_id]
		elsif params.has_key?(:item_id)
			@item_id = params[:item_id]
		else
			if Item.count > 0
				@item_id = Item.first.id
			else
				@item_id = nil
			end
		end
		@item = Item.exists?(@item_id) ? Item.find(@item_id) : nil
	end

	def set_list_view
  	if params.has_key?(:list_for)
	  	@list_for_an_item = params[:list_for] == "item"
	  elsif !cookies[:list_for_item].blank?
	  	@list_for_an_item = cookies[:list_for_item] == "1"
	  else
	  	@list_for_an_item = true
	  end
	  @list_for_a_trait = !@list_for_an_item
	  cookies[:list_for_item] = @list_for_an_item ? "1" : "0"
	end

	def set_trait_scope
		@trait_id = params[:item_spec][:trait_id]
		@trait = Trait.exists?(@trait_id) ? Trait.find(@trait_id) : nil
	end

	def set_visibility
		if !params.has_key?(:item_spec)
  		# cookies & params are "1" or "0", @variables are true or false
			params[:show_history] = cookies[:history] == "1" ? "1" : "0" #nil
	  	params[:show_pending] = cookies[:pending] == "1" ? "1" : "0" #nil
	  	params[:show_deleted] = cookies[:deleted] == "1" ? "1" : "0" #nil
	  end
	  
  	@history = params[:show_history] #== "1"
  	@pending = params[:show_pending] #== "1"
  	@deleted = params[:show_deleted] #== "1"

  	cookies[:history] = @history #? "1" : "0"
  	cookies[:pending] = @pending #? "1" : "0"
  	cookies[:deleted] = @deleted #? "1" : "0"

	 	@visibility = @history.to_i + (@pending.to_i * 4) + (@deleted.to_i * 8) + 18
		# @visibility = (@history ? 1 : 0) + (@pending ? 4 : 0) + (@deleted ? 8 : 0) + 18
	end

end
