class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def current_user
    current_scribe || current_magician || current_muggle || "guest"
  end
  
  def after_sign_in_path_for user
    books_path
  end
  
  helper_method :current_user
end
