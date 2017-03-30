require 'rails_helper'
require_relative '__version__'

def generate_3_occurrences_for_3_given_symptoms_for_given_user(symptoms, user, start_date)
  occ_1_symptom_1 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date - 1.second, symptom_id: symptoms[0].id)
  occ_1_symptom_2 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date - 1.second, symptom_id: symptoms[1].id)
  occ_1_symptom_3 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date - 1.second, symptom_id: symptoms[2].id)

  occ_2_symptom_1 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date + 1.second, symptom_id: symptoms[0].id)
  occ_2_symptom_2 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date + 1.second, symptom_id: symptoms[1].id)
  occ_2_symptom_3 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date + 1.second, symptom_id: symptoms[2].id)

  occ_3_symptom_1 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date + 2.days, symptom_id: symptoms[0].id)
  occ_3_symptom_2 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date + 2.days, symptom_id: symptoms[1].id)
  occ_3_symptom_3 = create(:occurrence_with_3_factor_instances, user_id: user.id, date: start_date + 2.days, symptom_id: symptoms[2].id)
  return occ_1_symptom_1, occ_1_symptom_2, occ_1_symptom_3, occ_2_symptom_1, occ_2_symptom_2, occ_2_symptom_3, occ_3_symptom_1, occ_3_symptom_2, occ_3_symptom_3
end

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

      # start_date                                end_date
      #      |                                       |
      #      |  o1_cur_user       o2_cur_user        |    o3_cur_user
      #      |  o1_user_x         o2_user_x          |    o3_user_x
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
            expect { post :create, report: @valid_report.to_json }.to have_enqueued_job.on_queue('mailers')
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

        context 'when an invalid report (without email, start_date, end_date and expiration_date) is given as parameter' do
          before(:each) do
            @invalid_report = {foo: 'bar'}
            post :create, report: @invalid_report.to_json
          end

          it 'responds with 422' do
            is_expected.to respond_with 422
          end

          it 'does not add the report in the database' do
            expect(Report.count).to eq 0
          end

          it 'does not enqueue a job to send a mail' do
            expect { post :create, report: @invalid_report.to_json }.not_to have_enqueued_job.on_queue('mailers')
          end
        end
      end
    end
  end

  describe '#show' do
    it { should route(:get, @version + '/report').to(action: :show) }

    context 'when no user is logged in' do
      it_behaves_like 'GET protected with authentication controller', :show
    end

    context 'when a user is logged in' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      #                  start_date                                       end_date
      #-----------------------|----------------------------------------------|---------
      #   occ_1_symptom_1     |      occ_2_symptom_1      occ_3_symptom_1    |
      #   occ_1_symptom_2     |      occ_2_symptom_2      occ_3_symptom_2    |
      #-----------------------|----------------------------------------------|---------
      #   occ_1_symptom_3     |      occ_2_symptom_3      occ_3_symptom_3    | <= those are not include in the report
      #-----------------------|----------------------------------------------|---------
      context 'when the logged in user has 3 occurrences of 3 symptoms and has created a report for the 2 latest occurrences of only 2 symptoms' do
        before(:each) do
          @start_date = Time.parse('2017-07-11 1:00')
          @end_date = @start_date + 1.week
          @expiration_date = @end_date + 2.weeks

          @symptoms = create_list(:symptom, 3)
          @occ_1_symptom_1, @occ_1_symptom_2, @occ_1_symptom_3, @occ_2_symptom_1, @occ_2_symptom_2, @occ_2_symptom_3, @occ_3_symptom_1, @occ_3_symptom_2, @occ_3_symptom_3 = generate_3_occurrences_for_3_given_symptoms_for_given_user(@symptoms, @user, @start_date)

          @report = create(:report, user_id: @user.id, start_date: @start_date, end_date: @end_date, expiration_date: @expiration_date)
          @report.occurrences << [@occ_2_symptom_1, @occ_2_symptom_2, @occ_3_symptom_1, @occ_3_symptom_2]
        end

        context 'when a second user has similar occurrences and similar report' do
          before(:each) do
            second_user = create(:user)
            occ_1_symptom_1, occ_1_symptom_2, occ_1_symptom_3, occ_2_symptom_1, occ_2_symptom_2, occ_2_symptom_3, occ_3_symptom_1, occ_3_symptom_2, occ_3_symptom_3 = generate_3_occurrences_for_3_given_symptoms_for_given_user(@symptoms, second_user, @start_date)

            second_report = create(:report, user_id: second_user.id, start_date: @start_date, end_date: @end_date, expiration_date: @expiration_date)
            second_report.occurrences << [occ_2_symptom_1, occ_2_symptom_2, occ_3_symptom_1, occ_3_symptom_2]
          end

          context 'when the given token and email are valid and associated to the same report' do
            before(:each) do
              @token = @report.token
              @email = @report.email
            end

            context 'when expiration_date is not passed yet' do
              before(:each) do
                @report.expiration_date = Time.now + 2.weeks
                @report.save
              end

              before(:each) do
                get :show, token: @token, email: @email
              end

              it 'responds with 200' do
                is_expected.to respond_with 200
              end

              it 'returns a JSON' do
                expect(response.body).to be_instance_of String
                expect { JSON.parse(response.body) }.not_to raise_exception
              end

              describe 'the response' do
                subject { JSON.parse(response.body) }

                it 'contains a key "report"' do
                  expect(subject).to have_key 'report'
                end

                describe 'the report' do
                  subject { JSON.parse(response.body)['report'] }

                  it 'has an id, user_id, start_date, end_date, email, token, expiration_date, symptoms' do
                    expect(subject).to have_key 'id'
                    expect(subject).to have_key 'user_id'
                    expect(subject).to have_key 'start_date'
                    expect(subject).to have_key 'end_date'
                    expect(subject).to have_key 'email'
                    expect(subject).to have_key 'token'
                    expect(subject).to have_key 'expiration_date'
                    expect(subject).to have_key 'symptoms'
                  end

                  it 'has not the key "occurrences"' do
                    expect(subject).not_to have_key 'occurrences'
                  end

                  it 'has the same token as the one given in parameter' do
                    expect(subject['token']).to eq @token
                  end

                  it 'has the same email as the one given in parameter' do
                    expect(subject['email']).to eq @email
                  end

                  describe 'the symptoms array' do
                    subject { JSON.parse(response.body)['report']['symptoms'] }

                    it 'contains 2 symptoms' do
                      expect(subject.length).to eq 2
                    end

                    it 'contains the symptom 1 and the symptom 2' do
                      expected_ids = [@symptoms[0].id, @symptoms[1].id]
                      expect(expected_ids).to include subject[0]['id']
                      expect(expected_ids).to include subject[1]['id']
                    end

                    it 'has 2 occurrences for each symptom' do
                      subject.each do |symptom|
                        expect(symptom['occurrences'].length).to eq 2
                      end
                    end

                    it 'has occ_2_symptom_1 and occ_3_symptom_1 for the first symptom and occ_2_symptom_2 and occ_3_symptom_2 for the second symptom' do
                      expected_ids_symptom_1 = [@occ_2_symptom_1.id, @occ_3_symptom_1.id]
                      expect(expected_ids_symptom_1).to include subject[0]['occurrences'][0]['id']
                      expect(expected_ids_symptom_1).to include subject[0]['occurrences'][1]['id']
                      expected_ids_symptom_2 = [@occ_2_symptom_2.id, @occ_3_symptom_2.id]
                      expect(expected_ids_symptom_2).to include subject[1]['occurrences'][0]['id']
                      expect(expected_ids_symptom_2).to include subject[1]['occurrences'][1]['id']
                    end

                    it 'has 3 factor_instances for each occurrence' do
                      subject.each do |symptom|
                        symptom['occurrences'].each do |occurrence|
                          expect(occurrence['factor_instances'].length).to eq 3
                        end
                      end
                    end
                  end
                end
              end
            end

            context 'when expiration_date is passed' do
              before(:each) do
                @report.expiration_date = Time.parse('2012-07-11 21:00')
                @report.save
              end

              before(:each) do
                get :show, token: @token, email: @email
              end

              it 'responds with status 404' do
                is_expected.to respond_with 404
              end
            end
          end

          context 'when the given token is valid but the given email is not associated to this token' do
            before(:each) do
              @token = @report.token
              @email = @report.email + 'something is wrong'
            end

            before(:each) do
              get :show, token: @token, email: @email
            end

            it 'responds with status 404' do
              is_expected.to respond_with 404
            end
          end

          context 'when no email is given as parameter' do
            before(:each) do
              @token = @report.token
            end

            before(:each) do
              get :show, token: @token
            end

            it 'responds with status 404' do
              is_expected.to respond_with 404
            end
          end

          context 'when no token is given' do
            before(:each) do
              @email = @report.email
            end

            before(:each) do
              get :show, email: @email
            end

            it 'responds with status 404' do
              is_expected.to respond_with 404
            end
          end
        end
      end
    end
  end
end
