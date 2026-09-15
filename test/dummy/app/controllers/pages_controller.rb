# A page the host lays out: the layout renders the rail for signed-in users.
class PagesController < ApplicationController
  def show
    @slug = params[:slug]
  end
end
