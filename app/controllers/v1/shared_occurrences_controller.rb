class  V1::SharedOccurrencesController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create
    ReportMailer.new_report_notification(current_user, nil).deliver_later
    render nothing: true, :status => 200
  end
end

