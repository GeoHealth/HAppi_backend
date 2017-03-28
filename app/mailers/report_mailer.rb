class ReportMailer < ApplicationMailer
  def new_report_notification(user, report)
    @title = 'Dear doctor,'
    @user = user
    @report = report
    mail to: @report.email, subject: "Report from HAppi user #{@user.first_name} #{@user.last_name}"
  end
end
