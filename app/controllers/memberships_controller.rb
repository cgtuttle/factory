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
		@is_index_table = true
		@membership = Membership.where("user_id = ? AND tenant_id = ?", @current_user.id, @current_tenant.id).first
		@role = @membership.role
		@tenants = Tenant.where("membership.role = ?", "owner")
		@memberships = Membership.where(tenant_id: current_tenant.id)
	end

	def edit
		@membership = Membership.find(params[:id])
	end

	def update
		if params[:commit] != 'Cancel'
			@membership.update_attributes(params[:membership])
			flash[:success] = "#{@membership.user.email} role changed to #{params[:membership][:role]}"
		else
			flash[:notice] = "Role edit canceled"
		end
		redirect_to memberships_path
	end

	def destroy
		@tenant = current_tenant
		@membership = Membership.find(params[:id])
		if @membership.destroy
			flash[:success] = "Membership deleted"
			redirect_to tenant_path(@tenant)
		end
	end

end
