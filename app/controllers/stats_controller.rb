class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def average
    render json: AverageStatsFactory.per_hour_for_user(current_user), status: 200
  end
end
