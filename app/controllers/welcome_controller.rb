class WelcomeController < ApplicationController
  def index
    render json: { status: "up and Running" }
  end
end