class ReportMailer < ApplicationMailer
  def new_report_notification(user, report)
    @user = user
    @report = report
    mail to: @user.email, subject: "Report from HAppi user"
  end
end
