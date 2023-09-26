require "spec_helper"

RSpec.describe Drivers::QueryService, type: :service do
  let(:account) { { authentication_token: "valid_token" } }
  let(:valid_params) { { name: "name-exists" } }
  let(:invalid_params) { { name: "non-existent-name" } }

  describe "#run!" do
    context "when the driver response is successful" do
      it "returns a list of drivers" do
        allow(Linehaul::DriverService).to receive(:new).and_return(
          double(fetch_drivers: { "success" => true, "drivers" => [{ "name" => "name-exists" }] })
        )
        service = Drivers::QueryService.new(account, valid_params)
        result = service.run!
        expect(result).to eq([{ "name" => "John" }])
        expect(service.errors).to be_empty
      end
    end

    context "when the driver response is not successful" do
      it "sets an error and error_code" do
        allow(Linehaul::DriverService).to receive(:new).and_return(
          double(fetch_drivers: { "success" => false, "error_message" => "Driver not found" })
        )
        service = Drivers::QueryService.new(account, invalid_params)
        result = service.run!
        expect(result).to eq(:driver_not_found)
      end
    end
  end
end
