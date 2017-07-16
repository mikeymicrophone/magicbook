class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def current_user
    current_scribe || current_magician || current_muggle
  end
end
