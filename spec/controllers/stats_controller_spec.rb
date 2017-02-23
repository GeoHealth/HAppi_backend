require 'rails_helper'

RSpec.describe StatsController, type: :controller do
  describe '#count' do
    it { should route(:get, '/stats/count').to(action: :count) }
    it_behaves_like 'GET protected with authentication controller', :average

    context 'with valid authentication headers' do
      number_of_symptoms_to_create = 2
      number_of_occurrence_to_create = 10

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      before(:each) do
        @symptoms = create_list(:symptom, number_of_symptoms_to_create)
        today = Date.new
        a_week_ago = today - 1.week
        two_weeks_ago = a_week_ago - 1.week
        @symptoms.each do |symptom|
          create_list(:occurrence, number_of_occurrence_to_create, user_id: @user.id, symptom_id: symptom.id, date: today)
          create_list(:occurrence, number_of_occurrence_to_create, user_id: @user.id, symptom_id: symptom.id, date: a_week_ago)
          create_list(:occurrence, number_of_occurrence_to_create, user_id: @user.id, symptom_id: symptom.id, date: two_weeks_ago)
        end
      end

      context 'without parameters' do
        before(:each) do
          get :count
        end

        it 'responds with status 200' do
          is_expected.to respond_with 200
        end

        describe 'the answer' do
          before(:each) do
            @parsed_response = JSON.parse(response.body)
          end

          it 'is a JSON' do
            expect(response.body).to be_instance_of(String)
            JSON.parse(response.body)
          end

          it 'contains a key name symptoms that is an array' do
            expect(@parsed_response).to have_key('symptoms')
            expect(@parsed_response['symptoms']).to be_an Array
          end

          it 'contains a key name unit that is equal to "days"' do
            expect(@parsed_response).to have_key('unit')
            expect(@parsed_response['unit']).to eq 'days'
          end

          describe 'each element of the array "symptoms"' do
            before(:each) do
              @symptoms = @parsed_response['symptoms']
            end

            it 'contains an id' do
              @symptoms.each do |symptom|
                expect(symptom).to have_key('id')
              end
            end

            it 'contains a name' do
              @symptoms.each do |symptom|
                expect(symptom).to have_key('name')
              end
            end

            it 'contains an array named "counts"' do
              @symptoms.each do |symptom|
                expect(symptom).to have_key('counts')
                expect(symptom['counts']).to be_an Array
              end
            end

            it 'does not contains useless attributes: short_description, long_description, category, gender_filter' do
              @symptoms.each do |symptom|
                expect(symptom).not_to have_key('short_description')
                expect(symptom).not_to have_key('long_description')
                expect(symptom).not_to have_key('category')
                expect(symptom).not_to have_key('gender_filter')
              end
            end

            describe 'each element of the array "counts"' do
              it 'has a date' do
                @symptoms.each do |symptom|
                  symptom['counts'].each do |average|
                    expect(average).to have_key('date')
                  end
                end
              end

              it 'has a count' do
                @symptoms.each do |symptom|
                  symptom['counts'].each do |average|
                    expect(average).to have_key('count')
                  end
                end
              end
            end
          end
        end
      end

    end
  end
end