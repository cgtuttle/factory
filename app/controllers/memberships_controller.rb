class MembershipsController < ApplicationController
	load_and_authorize_resource

	def new
		@tenant = current_tenant
		@membership = Membership.new(:tenant_id => @tenant.id)
	end

	def create
		@membership = Membership.new(params[:membership])
		@membership.save
	end

	def show
	end

	def index
		@is_table = true
		@membership = Membership.where("user_id = ? AND tenant_id = ?", @current_user.id, @current_tenant.id).first
		@role = @membership.role
		@tenants = Tenant.where("membership.role_name = ?", "owner")
		@memberships = Membership.where(tenant_id: current_tenant.id).joins(:tenant, :user, :role).order("display_order, tenants.name, users.email")
	end

	def edit
		@membership = Membership.find(params[:id])
	end

	def update
		@membership = Membership.find(params[:id])
		if @membership.update_attributes(params[:membership])
			flash[:success] = "#{@membership.user.email} role changed to #{params[:membership][:role]}"
			redirect_to memberships_path
		else
			render :action => :edit
		end
	end

	def destroy
		@tenant = current_tenant
		@membership = Membership.find(params[:id])
		if @membership.destroy
			flash[:success] = "Membership deleted"
			redirect_to :back
		end
	end

	def destroy_user
		@user = User.find(params[:user_id])
		@email = @user.email
		if @user.destroy
			flash[:success] = "#{@email} deleted"
			redirect_to :back
		end
	end

end
