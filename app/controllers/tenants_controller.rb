class TenantsController < ApplicationController
skip_around_filter :scope_current_tenant, :except => [:index, :new_membership, :destroy_membership]

	def new
		@tenant = Tenant.new
	end

	def create
		@tenant = Tenant.new(params[:tenant])
		if @tenant.save
			@membership = Membership.new(:tenant_id => @tenant.id, :user_id => current_user.id)
			if @membership.save

				redirect_to tenant_path(@tenant)
			end
		end
	end

	def show
		logger.debug "Running show #{}"
		@tenant = Tenant.find(params[:id])
		@memberships = @tenant.memberships
	end

	def index
	end

	def edit
		@tenant = Tenant.find(params[:id])
	end

	def update
		if !@user = User.find_by_email(params[:email])
			@email = params[:email]
			@user = User.create!(:email => @email, :password => 'password', :password_confirmation => 'password')
		end
		@membership = Membership.new(:tenant_id => params[:id], :user_id => @user.id)
		@membership.save	
		redirect_to tenant_path(current_tenant)
	end

	def destroy
	end

	def new_membership
		@tenant = current_tenant
		@membership = Membership.new(:tenant_id => @tenant.id)
	end

	def destroy_membership
		@tenant = current_tenant
		@membership = Membership.find(params[:id])
		if @membership.destroy
			flash[:success] = "Membership deleted"
			redirect_to tenant_path(@tenant)
		end
	end
end
