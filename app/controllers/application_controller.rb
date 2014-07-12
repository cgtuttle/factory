class ApplicationController < ActionController::Base
  protect_from_forgery
  force_ssl
  around_filter :scope_current_tenant # Run for each request...., return here at end of request (creates a wrapper around the request)
  before_filter :set_per_page
  before_filter :initialize_item, :initialize_property

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to tenants_path, :alert => exception.message
  end

  def tenant_set?
    @tenant_set = !!current_tenant
  end
  helper_method :tenant_set?

  def current_tenant # Called frequently - helper method, available anywhere
    @current_tenant ||= session[:current_tenant_id] && Tenant.find_by_id(session[:current_tenant_id])
  end
  helper_method :current_tenant

  def set_current_item
    initialize_item
  end
  helper_method :set_current_item

  def set_current_property
    initialize_property
  end
  helper_method :set_current_property


private

  def after_sign_in_path_for(resource)
    tenants_path
	end
    
  def current_ability
    @current_ability || Ability.new(current_user, current_tenant)
  end

  def initialize_item
    initialize_resources("item")
  end

  def initialize_property
    initialize_resources("property")
  end

  def initialize_resources(resource_name)
    if !current_tenant.blank?
      resource = resource_name.capitalize.constantize
      current_object = instance_variable_get("@#{resource_name}")
      cookie_name = "#{current_tenant.id}_#{resource_name}".to_sym
      if current_object.blank?
        current_id = cookies[cookie_name]
        if !current_id.blank? && resource.exists?(current_id)
          current_object = resource.find(current_id)
        else
          current_object = resource.first
        end
      end
      exists = !current_object.blank?
      cookies.delete cookie_name
      instance_variable_set("@#{resource_name}s_exist", exists)
      if exists
        cookies[cookie_name] = current_object.id
        instance_variable_set("@#{resource_name}", current_object)
      end
    end    
  end

	def scope_current_tenant # Runs once for each request 
    # .....do this next.......
    logger.debug "@@@@@@@@ Running scope_current_tenant @@@@@@@@"
    Tenant.current_id = current_tenant.id # Applies 'id' to the object returned by current_tenant
    yield # .....allow the rest of the application to do stuff.......
  ensure # .....then finish with this to clean up at end of request
    Tenant.current_id = nil
  end

  def set_per_page
    height = cookies[:height].blank? ? '801' : cookies[:height]
    logger.debug "height = #{height}"
    @per_page = 5
    @per_page = 10 if height > '700'
    @per_page = 12 if height > '800'
    @per_page = 16 if height > '900'
  end

end
