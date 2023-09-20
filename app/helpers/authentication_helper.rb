module AuthenticationHelper
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_account
  end

  def authenticate_account
    unless valid_authentication?
      render json: Loconav::Response::Builder.failure(errors: ["Authentication failed"])
    end
  end

  def valid_authentication?
    return false unless request.headers['User-Authentication'].present?
    !!current_account
  end

  def current_account
    @current_account ||= Linehaul::AuthService.new(auth_token).fetch_account
  end

  def auth_token
    request.headers['User-Authentication']
  end
end