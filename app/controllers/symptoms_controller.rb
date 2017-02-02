class SymptomsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    symptoms = nil
    if params[:name]
      symptoms = Symptom.where("name ilike ?", "%#{params[:name]}%")
    else
      symptoms = Symptom.all
    end
    render json: {symptoms: symptoms}, status: 200
  end
end
