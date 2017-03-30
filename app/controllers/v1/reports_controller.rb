class V1::ReportsController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create
    @report = ReportFactory.build_from_params(params.fetch(:report), current_user)
    if @report.save
      ReportMailer.new_report_notification(current_user, @report).deliver_later
      render json: @report, :include => :occurrences, status: 201
    else
      render nothing: true, status: 422
    end
  end

  def show
    @token = params.fetch(:token)
    @email = params.fecth(:email)
    @report = Report.find_by_token(@token)
    if @report.email == @email
      render json: @report.enhanceReportWithSymptoms, :include => :symptoms
    else
      render nothing: true, status: 404
    end
  end
end

