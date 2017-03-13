class SymptomsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
    if params.key?(:name)
      symptoms = Symptom.where('name ilike ?', "%#{params.fetch(:name).strip}%")
    else
      symptoms = Symptom.all
    end
    render json: {symptoms: symptoms}
  end

  def occurrences
    @symptoms = Symptom.includes(:occurrences).where(occurrences: {user: current_user})
    render json: {symptoms: @symptoms}, :include => :occurrences
  end
end
