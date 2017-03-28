require 'rails_helper'
require_relative '__version__'

RSpec.describe V1::ReportsController, type: :controller do
  describe '#create' do
    it { should route(:post, @version + '/reports').to(action: :create) }

    context 'when no user is logged in' do
      it_behaves_like 'POST protected with authentication controller', :create, report: {}
    end

    context 'when a user is logged in' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      # start_date                                              end_date
      #      |                                                     |
      #      |  o1_cur_user o1_user_x o2_cur_user o2_user_x        |    o3_cur_user  o3_user_x
      context 'when 3 occurrences exist for the current user, 2 included on the given interval and 3 occurrences for other users' do
        before(:each) do
          @valid_report = build(:report)

          @o1_cur_user = create(:occurrence, user_id: @user.id, date: @valid_report.start_date + 1.hour)
          @o1_user_x = create(:occurrence, date: @valid_report.start_date + 1.hour)
          @o2_cur_user = create(:occurrence, user_id: @user.id, date: @valid_report.start_date + 1.week)
          @o2_user_x = create(:occurrence, date: @valid_report.start_date + 1.week)
          @o3_cur_user = create(:occurrence, user_id: @user.id, date: @valid_report.end_date + 1.week)
          @o3_user_x = create(:occurrence, date: @valid_report.end_date + 1.week)
        end

        context 'when a valid report (with email, start_date, end_date and expiration_date) is given as parameter' do
          before(:each) do
            post :create, report: @valid_report.to_json
          end

          it 'responds with 201' do
            is_expected.to respond_with 201
          end

          it 'adds the report in the database' do
            expect(Report.count).to eq 1
          end

          it 'returns a JSON' do
            expect(response.body).to be_instance_of(String)
          end

          it 'enqueues a job to send a mail' do
            expect{post :create, report: @valid_report.to_json}.to have_enqueued_job.on_queue('mailers')
          end

          describe 'the response' do
            subject { JSON.parse(response.body) }

            it 'contains the report that has been saved' do
              expect(subject['email']).to eq @valid_report.email
              expect(Time.zone.parse(subject['start_date'])).to be_within(1.second).of @valid_report.start_date
              expect(Time.zone.parse(subject['end_date'])).to be_within(1.second).of @valid_report.end_date
              expect(Time.zone.parse(subject['expiration_date'])).to be_within(1.second).of @valid_report.expiration_date
            end

            it 'contains the generated ID' do
              expect(subject['id']).not_to be_nil
            end

            it 'contains the generated token' do
              expect(subject['token']).not_to be_nil
            end

            it 'is associated to the logged in user' do
              expect(subject['user_id']).to eq @user.id
            end

            it 'contains an array of attached occurrences' do
              expect(subject).to have_key('occurrences')
            end
          end

          describe 'the array of attached occurrences' do
            subject { JSON.parse(response.body)['occurrences'] }

            it 'contains 2 occurrences' do
              expect(subject.length).to eq 2
            end
          end
        end
      end
    end
  end
end
