require 'rails_helper'

RSpec.describe ReportFactory do
  def check_all_attributes(report, expected_report, expected_user)
    expect(report.email).to eq expected_report[:email]
    expect(report.start_date).to eq expected_report[:start_date]
    expect(report.end_date).to eq expected_report[:end_date]
    expect(report.expiration_date).to eq expected_report[:expiration_date]
    expect(report.user_id).to eq expected_user.id
  end

  def check_attached_occurrences(report, occurrences_attached, occurrences_not_attached)
    expect(report.occurrences).not_to be_nil
    expect(report.occurrences.length).to eq occurrences_attached.length
    occurrences_attached.each do |occurrence|
      expect(report.occurrences).to include(occurrence)
    end

    occurrences_not_attached.each do |occurrence|
      expect(report.occurrences).not_to include(occurrence)
    end
  end

  describe '.build_from_params' do
    subject { ReportFactory.build_from_params report, user }

    start_date = Time.zone.parse('2005-10-10 10:10:10')
    end_date = start_date + 2.weeks
    expiration_date = end_date + 2.weeks
    valid_report = {
        email: 'valid@mail.com',
        start_date: start_date,
        end_date: end_date,
        expiration_date: expiration_date
    }
    invalid_report = {
        invalid_key: 'no good',
        foo: 'bar'
    }


    context 'when a valid user is given' do
      before(:each) do
        @valid_user = create(:user)
      end

      let (:user) { @valid_user }

      # start_date                                              end_date
      #      |                                                     |
      #      |  o1_cur_user o1_user_x o2_cur_user o2_user_x        |    o3_cur_user  o3_user_x
      context 'when 3 occurrences exist for the current user, 2 included on the given interval and 3 occurrences for other users' do
        before(:each) do
          @o1_cur_user = create(:occurrence, user_id: @valid_user.id, date: start_date + 1.hour)
          @o1_user_x = create(:occurrence, date: start_date + 1.hour)
          @o2_cur_user = create(:occurrence, user_id: @valid_user.id, date: start_date + 1.week)
          @o2_user_x = create(:occurrence, date: start_date + 1.week)
          @o3_cur_user = create(:occurrence, user_id: @valid_user.id, date: end_date + 1.week)
          @o3_user_x = create(:occurrence, date: end_date + 1.week)
        end

        context 'when a valid report (containing an email, start_date, end_date and expiration_date keys) is given' do
          let (:report) { valid_report.as_json }

          it 'returns an instance of Report' do
            expect(subject).to be_an_instance_of(Report)
          end

          it 'returns an instance with all attributes set to the given values' do
            check_all_attributes subject, valid_report, @valid_user
          end

          it 'returns an instance attached to the 2 occurrences of the logged in user that are between start_date and end_date' do
            check_attached_occurrences subject, [@o1_cur_user, @o2_cur_user], [@o1_user_x, @o2_user_x, @o3_cur_user, @o3_user_x]
          end
        end

        context 'when a valid report (containing an email, start_date, end_date and expiration_date keys) is given as a json string' do
          let (:report) { valid_report.to_json }

          it 'returns an instance of Report' do
            expect(subject).to be_an_instance_of(Report)
          end

          it 'returns an instance with all attributes set to the given values' do
            check_all_attributes subject, valid_report, @valid_user
          end

          it 'returns an instance attached to all occurrences of the logged in user that are between start_date and end_date' do
            check_attached_occurrences subject, [@o1_cur_user, @o2_cur_user], [@o1_user_x, @o2_user_x, @o3_cur_user, @o3_user_x]
          end
        end

        context 'when the given json contains none of the following key: containing an email, start_date, end_date and expiration_date' do
          let (:report) { invalid_report.to_json }

          it 'returns an instance of Report' do
            expect(subject).to be_an_instance_of(Report)
          end

          it 'has all its attributes set to nil and zero occurrences attached' do
            expect(subject.email).to be_nil
            expect(subject.start_date).to be_nil
            expect(subject.end_date).to be_nil
            expect(subject.expiration_date).to be_nil
            expect(subject.occurrences).to be_empty
          end
        end
      end
    end
  end
end
