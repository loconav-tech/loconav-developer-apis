module AuthenticationHelper
  extend ActiveSupport::Concern

  HEADER_USER_AUTHENTICATION = Rails.application.secrets.header_user_authentication

  def authenticate_account
    unless valid_token?
      render json: Loconav::Response::Builder.failure(errors: ["Authentication failed"]), status: :unauthorized
    end
  end

  def valid_token?
    return false unless auth_token.present?

    !!current_account
  end

  def current_account
    begin
      @current_account ||= Linehaul::AuthService.new(auth_token).fetch_account
    rescue
      nil
    end
  end

  def auth_token
    request.headers[HEADER_USER_AUTHENTICATION]
  end
end
