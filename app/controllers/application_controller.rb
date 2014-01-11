class ApplicationController < ActionController::Base
  protect_from_forgery
  around_filter :scope_current_tenant
  before_filter :scope_current_item
  before_filter :set_per_page

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to tenants_path, :alert => exception.message
  end

  def tenant_set?
    logger.debug "Running tenant_set?"
    @tenant_set = !!current_tenant
  end
  helper_method :tenant_set?

  def current_tenant
    @current_tenant ||= session[:current_tenant_id] && Tenant.find_by_id(session[:current_tenant_id])
  end
  helper_method :current_tenant

  def current_item
    @current_item ||= session[:current_item_id] && Item.find_by_id(session[:current_item_id])
    @current_item ||= Item.first
  end
  helper_method :current_item

private

  def after_sign_in_path_for(resource)
    tenants_path
	end

	def scope_current_tenant
    logger.debug "Running scope_currrent_tenant: current_tenant.id = #{current_tenant.id}"
    Tenant.current_id = current_tenant.id
    yield
  ensure
    Tenant.current_id = nil
  end

  def scope_current_item
    if current_item
      Item.current_id = current_item.id
      logger.debug "Item.current_id = #{Item.current_id}"
    end
  end

  def set_per_page
    height = cookies[:height].blank? ? '800' : cookies[:height]
    logger.debug "height = #{height}"
    @per_page = 5
    @per_page = 10 if height > '700'
    @per_page = 12 if height > '800'
    @per_page = 16 if height > '900'
  end
    

  def current_ability
    logger.debug "running current_ability"
    @current_ability || Ability.new(current_user, current_tenant)
  end

end
