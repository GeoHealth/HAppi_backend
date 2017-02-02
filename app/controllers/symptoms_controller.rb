class SymptomsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render json: {symptoms: Symptom.all}, status: 200
  end
end
