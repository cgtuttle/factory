class SpecificationsController < ApplicationController
	include ApplicationHelper
	require 'will_paginate/array'
	before_filter :initialize_status_checkboxes, :find_items, :find_traits
	load_and_authorize_resource 

	def cancel
		@specification = Specification.find(params[:id])
		@specification.canceled = true
		@specification.set_eff_date
		@specification.set_version
		if @specification.save
			flash[:success] = "Future Item Trait canceled"
			redirect_to specifications_path :item_id => @specification.item_id
		else
			redirect_to specifications_path :item_id => @specification.item_id
		end
	end

	def copy
		@specification = Specification.find(params[:id])		
		@items = Item.where("id NOT IN (?)", @specification.item_id).order(:code)
	end
	
	def create
		@new_specification = Specification.new(params[:specification])
		@new_specification.set_eff_date
		@new_specification.set_version
		@new_specification.set_editor(current_user.email)
		if @new_specification.save!
			flash[:success] = "Item Trait added/changed"
			redirect_to specifications_path :item_id => params[:specification][:item_id]
		else
			render :new
		end
	end

	def destroy
		@delete_specification = @specification.dup
		@delete_specification.deleted = true
		@delete_specification.eff_date = Date.today
		@delete_specification.set_version
		@delete_specification.set_editor(current_user.email)
		if @delete_specification.save!
			flash[:success] = "Item Trait deleted"
			redirect_to specifications_path :item_id => @specification.item_id
		else
			flash[:alert] = "Could not delete Item Trait"
			redirect_to specifications_path :item_id => @specification.item_id
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
			@specifications = Specification.includes(:trait => :category).where(:item_id => @item).order("categories.display_order")
			@categories = @specifications.group_by{|is| is.trait.category}		
		end
	end

	def edit
		@new_specification = @specification.dup
		@new_specification.eff_date = Date.today
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
			if params.has_key?(:specification)
				@item_id = params[:specification][:item_id]
				@item = Item.exists?(@item_id) ? Item.find(@item_id) : nil
			end
			set_current_item
	  	if @item
		  	@new_specification = Specification.new
				@specifications = Specification.visible_by_item(@item.id, @visibility).paginate(:page => params[:page], :per_page => 15) #main Specification retrieval
				@index = @specifications
				@items = Item.order(:code)				
			else
				flash[:alert] = "No items exist. Please add at least one."
				redirect_to items_path
			end
		else # @list_for_a_trait
			if params.has_key?(:specification)
				@trait_id = params[:specification][:trait_id]
				@trait = Trait.exists?(@trait_id) ? Trait.find(@trait_id) : nil
			end
			set_current_trait
			if @trait
				@new_specification = Specification.new
				@specifications = Specification.visible_by_trait(@trait.id, @visibility).paginate(:page => params[:page], :per_page => 15) #main Specification retrieval
				@index = @specifications
				@current_traits = Specification.where(:item_id => @item.id).pluck(:trait_id)
				@traits = Trait.where('id IN (?)', @current_traits).order(:code)				
			end
		end
  end
	
  def new
  	set_item_scope
  	if @item
	  	@current_traits = Specification.where(:item_id => @item.id).pluck(:trait_id)
	  	@available_traits = Trait.where('id not in (?)', @current_traits )
	  	@new_specification = Specification.new
	  end
  end

	def notes
		@specification = Specification.find(params[:id])
		@is_edit_form = true
	end

  def paste
		@specification = Specification.find(params[:id])
		@item_list = params[:copy_to][:items]
		@set_eff_date = params[:eff_date][:copy] != '1'
		ttl = 0
		success = 0
		@item_list.each do |i|
			@new_specification = @specification.dup
			@item = Item.where("code = ?", i).first
			@new_specification.item_id = @item.id
			@new_specification.eff_date = Date.today if @set_eff_date
			if @new_specification.save
				ttl += 1
				success += 1
			else
				ttl += 1
			end
		end		
		flash[:success] = "#{@specification.trait.code} copied to #{success} of #{ttl} items"
		redirect_to specifications_path :item_id => @specification.item_id
	end

	def update
		if @specification.update_attributes(params[:specification])
			flash[:success] = "Notes updated"
			redirect_to specifications_path :item_id => @specification.item_id
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
		elsif params.has_key?(:specification)
			@item_id = params[:specification][:item_id]
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
		@trait_id = params[:specification][:trait_id]
		@trait = Trait.exists?(@trait_id) ? Trait.find(@trait_id) : nil
	end

	def set_visibility
		if !params.has_key?(:specification)
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
