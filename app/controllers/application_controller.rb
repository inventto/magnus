class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_user!
  after_filter :store_latest_pages_visited

  def store_latest_pages_visited
    return unless request.get?
    return if request.xhr?

    session[:latest_pages_visited] ||= []
    session[:latest_pages_visited] << request.path_parameters
    session[:latest_pages_visited].delete_at 0 if session[:latest_pages_visited].size == 6
  end

end
