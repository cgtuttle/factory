class StaticPagesController < ApplicationController
	
	before_filter :authenticate_user!, :except => [:home]
	skip_around_filter :scope_current_tenant, :except => [:tenant]

  def home
  end

  def company
    logger.debug "Running company #{}"
    @user = current_user
    @tenants = current_user.tenants
  	if @tenants.count>1
  		@select_tenant = true
    elsif @tenants.empty?
      @no_tenant = true
  	else
  		@tenant = @tenants.first
  	end
  end

  def update
    logger.debug "Running update#{}"
    session[:tenant_id] = params[:tenant_id]
    redirect_to "/tenant"
  end  

  def tenant
    logger.debug "current_tenant: #{current_tenant.inspect}"
    @users = current_tenant.users
  end

end
