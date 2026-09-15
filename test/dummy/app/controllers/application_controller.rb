# A host with hand-rolled sessions: a signed cookie names the user, resumed before every
# action. The engine's controllers inherit this, so Current.user is set by the time
# Redpen.author asks for it.
class ApplicationController < ActionController::Base
  before_action :resume_session

  private
    def resume_session
      Current.user = User.find_by(id: cookies.signed[:user_id])
    end

    def signed_in? = Current.user.present?
    helper_method :signed_in?
end
