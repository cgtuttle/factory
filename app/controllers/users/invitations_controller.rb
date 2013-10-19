class Users::InvitationsController < Devise::InvitationsController
	skip_around_filter :scope_current_tenant, :only => [:edit, :update]

# POST /resource/invitation
  def create
  	if User.exists?(email: params[:user][:email])
  		@user = User.find_by_email(params[:user][:email])
  		@user.invite!(current_inviter)
  	else
			@user = invite_user
		end
		@membership = add_membership

    if @user.errors.empty?
      set_flash_message :notice, :send_instructions, :email => @user.email if @user.invitation_sent_at
      respond_with @user, :location => after_invite_path_for(@user)
    else
      respond_with_navigational(@user) { render :new }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    @user = User.find_by_invitation_token(params[:invitation_token])
    logger.debug "@user.sign_in_count: #{@user.sign_in_count}"
    if @user.sign_in_count > 0
      @user.invitation_token = nil
      @user.save
      redirect_to "/login"
    else
      resource.invitation_token = params[:invitation_token]
      render :edit
    end
  end


	protected

  def invite_user
  	User.invite!({:email => params[:user][:email]}, current_inviter)
  end

  def add_membership
  	Membership.create(:tenant_id => current_tenant.id, :user_id => @user.id, :role => "user")
  end

  def current_inviter
    @current_inviter ||= authenticate_inviter!
  end

end