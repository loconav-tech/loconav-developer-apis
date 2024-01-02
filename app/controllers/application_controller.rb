class ApplicationController < ActionController::API
  include ThrottlerHelper
  before_action :throttle_client
end
