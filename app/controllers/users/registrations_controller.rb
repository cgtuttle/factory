class Users::RegistrationsController < Devise::RegistrationsController

	def new
		logger.debug "Running users.registrations_controller.new"
		super
	end

	def create
		logger.debug "Running users.registrations_controller.create"
		super
	end

	def update
		logger.debug "Running users.registrations_controller.update"
		super
	end

	private

  def after_update_path_for(resource)
    tenants_path
  end

end