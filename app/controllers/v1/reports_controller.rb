class V1::ReportsController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:show]

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
    begin
      @report = Report.find_by_token(params.fetch(:token))
      if @report && @report.expiration_date > Time.zone.now && @report.email == params.fetch(:email)
        render json: {report: @report.enhanceReportWithSymptoms}, :include => {:symptoms => {:include => {:occurrences => {:include => :factor_instances}}}}
      else
        render nothing: true, status: 404
      end
    rescue ActionController::ParameterMissing
      render nothing: true, status: 404
    end
  end
end

