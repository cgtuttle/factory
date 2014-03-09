class PagesController < ApplicationController
	skip_around_filter :scope_current_tenant
  skip_before_filter {initialize_resources ("item")}
#	skip_before_filter :scope_current_item

  def enter
  	@fixed = true
  	@body_class = "static-page"
  end

  def about
  	@fixed = true
  	@body_class = "static-page"
  end

end
