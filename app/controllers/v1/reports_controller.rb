class V1::ReportsController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create
    @report = ReportFactory.build_from_params(params.fetch(:report), current_user)
    if @report.save
      ReportMailer.new_report_notification(current_user, @report).deliver_later
      render json: @report, :include => :occurrences, status: 201
    else
      render nothing: true, status: 400
    end
  end
end

