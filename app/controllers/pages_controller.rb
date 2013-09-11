class PagesController < ApplicationController
	skip_around_filter :scope_current_tenant
	skip_before_filter :scope_current_item

  def enter
  	@fixed = true
  end
  
end
