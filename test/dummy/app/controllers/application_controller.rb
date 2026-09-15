# A host shaped like Rails' authentication generator: a signed cookie names the user,
# every action requires one unless the controller opts out by name, and the redirect
# names a host route. The engine's controllers inherit all of it.
class ApplicationController < ActionController::Base
  before_action :require_authentication

  class << self
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def require_authentication
      resume_session || redirect_to(new_session_path)
    end

    def resume_session
      Current.user = User.find_by(id: cookies.signed[:user_id])
    end

    def signed_in? = Current.user.present?
    helper_method :signed_in?
end
