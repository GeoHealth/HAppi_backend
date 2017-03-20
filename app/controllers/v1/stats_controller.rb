class  V1::StatsController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  rescue_from(*[ActionController::ParameterMissing, ArgumentError]) do
    render :nothing => true, :status => 400
  end

  def count
    render json: SymptomsCountsFactory.build_for(current_user.id, Time.zone.parse(Time.parse(params.fetch(:start)).to_s), Time.zone.parse(Time.parse(params.fetch(:end)).to_s), params[:unit], params[:symptoms])
  end
end

