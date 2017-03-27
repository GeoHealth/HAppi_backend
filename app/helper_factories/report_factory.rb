class ReportFactory
  def self.build_from_params(json_report, current_user)
    json_report = JSON.parse(json_report) if json_report.class.equal?(String)

    report = Report.new
    report.user_id = current_user.id
    if json_report
      report.email = json_report.fetch('email', nil)
      report.start_date = json_report.fetch('start_date', nil)
      report.end_date = json_report.fetch('end_date', nil)
      report.expiration_date = json_report.fetch('expiration_date', nil)
    end
    attach_concerned_occurrences(report, current_user)

    report
  end

  def self.attach_concerned_occurrences(report, user)
    report.occurrences = Occurrence.where('user_id = :user_id AND (date BETWEEN :start_date AND :end_date)',
                                          {user_id: user.id, start_date: Time.zone.parse(report.start_date.to_s), end_date: Time.zone.parse(report.end_date.to_s)})
  end
end