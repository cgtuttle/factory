class UsersController < ApplicationController

	def show
	end

	def index
		@users = current_tenant.users
	end

	def edit
	end

	def update
	end

end
