class ImportsController < ApplicationController
	load_and_authorize_resource
		

	def new
		logger.info "Running ImportsController::new"
		@model = params[:model] if params[:model]
		@is_edit_form = true
	end

	def import
		logger.info "Running ImportsController::import"
	end
	
	
end
