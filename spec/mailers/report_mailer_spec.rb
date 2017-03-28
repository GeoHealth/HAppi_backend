require 'rails_helper'

RSpec.describe ReportMailer, type: :mailer do
  describe '#new_report_notification' do
    before(:each) do
      @user = build(:user, first_name: 'Foo', last_name: 'Bar')
      @report = build(:report, token: 'a_unique_token_that_is_generated_on_report_save')
      @mail = ReportMailer.new_report_notification(@user, @report)
    end

    it 'sends the mail' do
      expect { @mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'creates a mail with the recipient extracted from the report' do
      expect(@mail.to).to eq [@report.email]
    end

    it 'sends the mail from "geohealth.info@gmail.com"' do
      expect(@mail.from).to eq ['geohealth.info@gmail.com']
    end

    it 'sends the mail with subject "Report from HAppi user Foo Bar"' do
      expect(@mail.subject).to eq 'Report from HAppi user Foo Bar'
    end

    it 'sends the mail with the body containing a URL with the generated token' do
      expect(@mail.encoded).to include" https://happi-doctor.be?token=#{@report.token}&email=#{@report.email}"
    end
  end
end
