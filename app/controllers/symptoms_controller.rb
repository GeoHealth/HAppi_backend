class SymptomsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
    if params[:name]
      symptoms = Symptom.where("name ilike ?", "%#{params[:name]}%")
    else
      symptoms = Symptom.all
    end
    render json: {symptoms: symptoms}, status: 200
  end
end
