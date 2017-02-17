class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def average
    symptoms = Symptom.all
    render json: {symptoms: symptoms}, :except => [:short_description, :long_description, :category, :gender_filter], status: 200
  end
end
