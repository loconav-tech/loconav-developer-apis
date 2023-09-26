require "spec_helper"

RSpec.describe Api::V1::DriversController, type: :controller do
  let(:valid_account) { create(:account) }
  let(:valid_driver_param) { { name: "a" } }
  let(:empty_driver_param) { { name: "" } }

  describe "Index API" do
    context "When authentication is successful" do
      before do
        allow(controller).to receive(:current_account).and_return(valid_account)
      end

      it "returns a successful response" do
        get :index, params: valid_driver_param
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
