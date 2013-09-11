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
	end

	def edit
		@membership = Membership.find(params[:id])
	end

	def update
		@membership.update_attributes(params[:membership])
		redirect_to tenant_path(current_tenant)
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
