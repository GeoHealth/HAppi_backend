class StatsController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  rescue_from(*[ActionController::ParameterMissing, ArgumentError]) do
    render :nothing => true, :status => 400
  end

  def count
    render json: SymptomsCountsFactory.build_for(current_user.id, Time.parse(params.fetch(:start)), Time.parse(params.fetch(:end)), params[:unit], params[:symptoms])
  end
end

