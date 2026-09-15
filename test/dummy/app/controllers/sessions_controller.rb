class SessionsController < ApplicationController
  allow_unauthenticated_access

  def new
    render html: "Sign in", layout: false
  end

  def create
    cookies.signed[:user_id] = params[:user_id]
    redirect_to params[:return_to] || root_path
  end

  def destroy
    cookies.delete(:user_id)
    redirect_to root_path
  end
end
