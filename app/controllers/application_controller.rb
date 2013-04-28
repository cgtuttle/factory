class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :scope_current_tenant

  def after_sign_in_path_for(resource)  	
 		company_path
	end

	def current_tenant
  	Tenant.find(session[:tenant_id])
	end
	helper_method :current_tenant

private

	def scope_current_tenant
		Tenant.current_id = current_tenant.id
logger.debug "Running scope_current_tenant - Scoping current tenant"
    yield
  ensure
logger.debug "Running scope_current_tenant - Destroying current tenant"
    Tenant.current_id = nil
	end

	
end
