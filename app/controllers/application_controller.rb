class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_500

  private

  def handle_500(exception)
    Rails.logger.error(exception)
    Rails.logger.error(exception.backtrace.join("\n"))
    response = Loconav::Response::Builder.failure(errors: [{
                                                             message: "Something went wrong",
                                                             code: :internal_server_error,
                                                           }])
    render json: response, status: :internal_server_error
  end
end
