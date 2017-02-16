class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def symptoms
    @symptoms = Symptom.includes(:occurrences).where(occurrences: {user_id: current_user.id})
    render json: {symptoms: @symptoms}, :include => [:occurrences], :except => [:short_description, :long_description, :category, :gender_filter], status: 200
  end
end
