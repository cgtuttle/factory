class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :scope_current_tenant

  def after_sign_in_path_for(resource)  	
 		company_path
	end

	def current_tenant
		if user_signed_in?
			if current_user.tenants.count > 1
				if session[:tenant_id] 
					if current_user.tenants.exists?(session[:tenant_id])
	  				Tenant.find(session[:tenant_id])
	  			else
	  				flash[:error] = "The session tenant id doesn't exist for this user!"
	  			end
	  		end
	  	else
	  		current_user.tenants.first
	  	end
	  end
	end
	helper_method :current_tenant

	def tenant_set?
		!!current_tenant
	end
	helper_method :tenant_set?

private

	def scope_current_tenant
		Tenant.current_id = current_tenant.id
		logger.debug "Running scope_current_tenant - Scoping current tenant"
		logger.debug "current_tenant = #{current_tenant.inspect}"
    yield
  ensure
		logger.debug "Running scope_current_tenant - Destroying current tenant"
    Tenant.current_id = nil
	end

	
end
