# A page the host lays out: the layout renders the rail for signed-in users.
class PagesController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session

  def show
    @slug = params[:slug]
  end
end
