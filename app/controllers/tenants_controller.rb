class TenantsController < ApplicationController
	before_filter :authenticate_user!
	skip_around_filter :scope_current_tenant

  def new
		@tenant = Tenant.new
	end

  def create
		@tenant = Tenant.new(params[:tenant])
		if @tenant.save
			@membership = Membership.new(:tenant_id => @tenant.id, :user_id => current_user.id)
			if @membership.save
				set_current_tenant(@tenant)
				redirect_to tenant_path(@tenant)
			end
		end
	end

	def show
		@is_list_table = true
		@tenant ||= Tenant.find(params[:id])
		@memberships = @tenant.memberships
		@roles = Membership::ROLES
	end

	def index
		@is_list_table = true
		@tenants ||= current_user.tenants
		if @tenants.count == 1
			@tenant = @tenants.first
			set_current_tenant(@tenant)
			if can? :manage, :all
				redirect_to tenant_path(@current_tenant)
			else
				redirect_to display_item_specs_path
			end
		end
	end

	def edit
		@tenant = Tenant.find(params[:id])
	end

	def update
		logger.debug "running Tenants.update: #{params[:id]}"
		@tenant = Tenant.find(params[:id])
		@tenant.update_attributes(params[:tenant])	
		if can? :manage, :all
			redirect_to tenant_path(@current_tenant)
		else
			redirect_to display_item_specs_path
		end
	end

	def destroy
	end

	def set
	  set_current_tenant(params[:id])
	  if can? :manage, :all
			redirect_to tenant_path(@current_tenant)
		else
			redirect_to display_item_specs_path
		end
  end

private

	def set_current_tenant(id)
		logger.debug "running set_current_tenant: #{id}"
		session[:current_tenant_id] = id
		@current_tenant = Tenant.find_by_id(id)
		logger.debug "@current_tenant: #{@current_tenant}"
	end
end
