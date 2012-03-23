class BadgesController < ApplicationController
   before_filter :require_sign_in, :only => :update
   
  def index
    @badges = Badge.all.sort_by!{ |badge| badge.users.count }.reverse
    @display_avatar = get_display_avatar
  end

  def show
    @badge = Badge.find(params[:id])
    current_user.badge_id = @badge.id
    current_user.save
  end

  def update
    if current_user
      Badgehistory.create!(:user_id => current_user.id, 
                          :badge_id => params[:id], 
                          :user_followers_snapshot => Twitter.user(current_user.username).followers_count
                          )
      current_user.create_notablee_url
      @display_avatar = get_display_avatar
    else
      redirect_to auth_twitter_path
    end
  end
  
  private
  def require_sign_in
    if !current_user
      session[:user_return_to] = request.env['PATH_INFO']
      redirect_to auth_twitter_path
    end
  end
end
