class UsersController < ApplicationController

	def destroy
    @user = User.find(params[:id])
    if @user.destroy
        redirect_to :back
    end
  end
end
