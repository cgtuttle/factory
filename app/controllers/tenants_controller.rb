class TenantsController < ApplicationController
	before_filter :authenticate_user!
	skip_around_filter :scope_current_tenant
	load_and_authorize_resource :except => [:index, :set, :new, :create]

  def new
		@tenant = Tenant.new
	end

  def create
		@tenant = Tenant.new(params[:tenant])
		if @tenant.save
			@role= Role.find_by_role_name("owner")
			@membership = Membership.new(:tenant_id => @tenant.id, :user_id => current_user.id, :role_id => @role.id)
			if @membership.save
				set_current_tenant(@tenant)
				redirect_to tenant_path(@tenant)
			end
		end
	end

	def show
		@tenant ||= Tenant.find(params[:id])
		@memberships = @tenant.memberships
		@roles = Role.for_list
	end

	def index
		@is_table = true
		@tenants ||= current_user.tenants.all(:order => 'name')
	end

	def edit
		@tenant = Tenant.find(params[:id])
	end

	def update
		@tenant = Tenant.find(params[:id])
		@tenant.update_attributes(params[:tenant])	
		if can? :manage, :all
			redirect_to tenants_path
		else
			redirect_to display_item_specs_path
		end
	end

	def destroy
	end

	def set
	  set_current_tenant(params[:id])
	  flash[:success] = "You successfully switched to #{current_tenant.name}"
	  if can? :manage, @current_tenant
			redirect_to tenants_path
		else
			redirect_to display_item_specs_path
		end
  end

private

	def set_current_tenant(id)
		session[:current_tenant_id] = id
		@current_tenant = Tenant.find_by_id(id)
	end
end
