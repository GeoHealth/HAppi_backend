class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  rescue_from ActionController::ParameterMissing do
    render :nothing => true, :status => 400
  end

  def count
    render json: SymptomsCountsFactory.build_for(current_user.id, Time.zone.parse(params.fetch(:start)), Time.zone.parse(params.fetch(:end)), params[:unit], params[:symptoms])
  end
end
