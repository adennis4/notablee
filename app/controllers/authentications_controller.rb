class AuthenticationsController < ApplicationController

  def index
    @authentications = current_user.authentications if current_user
  end
  
  def create
    # render :text => request.env["omniauth.auth"].to_yaml
    
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    
    if authentication
      flash[:notice] = "Authentication Successful with Twitter"
      sign_in_and_redirect(:user, authentication.user)
      username = omniauth['info']['nickname']
      user_image = User.get_user_image_url(username)
      current_user.avatar_url = user_image
      current_user.save
    elsif current_user #this requires that a user sign into notablee before creating an authentication. 
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      authentication.oauth_token = omniauth['credentials']['token']
      authentication.oauth_secret = omniauth['credentials']['secret']
      flash[:notice] = "Authentication Successful"
      redirect_to root_path
    else
      user = User.new
      User.apply_params(omniauth, user)

      if user.save
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication"
    redirect_to root_path
  end
end
