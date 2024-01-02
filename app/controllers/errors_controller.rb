class ErrorsController < ApplicationController
  def not_found
    response = Loconav::Response::Builder.failure(errors: [{
                                                             message: "No API available",
                                                             code: :not_found,
                                                           }])
    render json: response, status: :not_found
  end

  def internal_server_error
    response = Loconav::Response::Builder.failure(errors: [{
                                                             message: "Something went wrong",
                                                             code: :internal_server_error,
                                                           }])
    render json: response, status: :internal_server_error
  end
end
