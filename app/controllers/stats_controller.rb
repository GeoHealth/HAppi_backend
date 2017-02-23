class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def count
    render json: SymptomsCountsFactory.per_hour_for_user(current_user, params[:start], params[:end], params[:unit], params[:symptoms])
  end
end
