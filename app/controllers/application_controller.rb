class ApplicationController < ActionController::Base
  protect_from_forgery
  #Including the helper SessionHelper into the app controller
  #to be available for all the controllers
  #all the helpers are by default available in all the views.
  include SessionsHelper
end
