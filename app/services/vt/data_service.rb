module Vt
  class DataService

    include UtilHelper, ResponseHelper, VtHelper

    attr_accessor :auth_token, :status_code, :errors

    def initialize
      self.errors = []
    end

    def run!
      vt_lookups
    end
  end
end
