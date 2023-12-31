module Api
  module V1
    module Vehicle
      module Video
        class DataController < ApplicationController
          include AuthenticationHelper

          before_action :authenticate_account

          def index
            service = ::Vt::DataService.new
            data = service.run!
            status_code = to_status(service)
            response = if service.errors.present?
                         Loconav::Response::Builder.failure(errors: [{ message: service.errors.join(", "),
                                                                       code: service.status_code,
                                                                     }])
                       else
                         Loconav::Response::Builder.success(values: data)
                       end
            render json: response, status: status_code
          end

          private def to_status(service)
            if service.status_code
              if service.error_code.in?(%i[ ])
                :bad_request
              elsif service.error_code.in?(%i[technical_issue data_not_found])
                :unprocessable_entity
              end
            else
              :ok
            end
          end
        end

      end
    end
  end
end

