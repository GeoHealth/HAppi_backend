class ReportMailer < ApplicationMailer
  def new_report_notification(user, report)
    @user = user
    @report = report
    mail to: 'tanguy.vaessen@gmail.com', subject: "Report from HAppi user"
  end
end
