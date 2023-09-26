require "spec_helper"

RSpec.describe Api::V1::DriversController, type: :controller do

  let(:valid_auth_token) { 'NGuyXn9TsUVt_UpYjCzs' }
  let(:valid_driver_param) { { name: "a" } }

  describe 'GET #index' do
    context 'when authentication is successful' do
      before do
        allow(controller).to receive(:valid_token?).and_return(true)
        allow(controller).to receive(:current_account).and_return({ 'authentication_token' => valid_auth_token })
      end

      it 'returns a successful response' do
        get :index, params: valid_driver_param
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when authentication fails' do
      before do
        allow(controller).to receive(:valid_token?).and_return(false)
      end

      it 'returns an unauthorized response' do
        get :index, params: valid_driver_param
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
