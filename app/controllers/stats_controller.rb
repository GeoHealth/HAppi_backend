class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def count
    render json: SymptomsCountsFactory.build_for(current_user, params[:start], params[:end], params[:unit], params[:symptoms])
  end
end
