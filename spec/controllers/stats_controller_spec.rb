require 'rails_helper'
require 'support/shared_example_symptom_count_factory'

RSpec.describe StatsController, type: :controller do
  describe '#count' do
    it { should route(:get, '/stats/count').to(action: :count) }
    it_behaves_like 'GET protected with authentication controller', :count

    context 'with valid authentication headers' do
      number_of_symptoms = 2

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      before(:each) do
        @user, @symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec(number_of_symptoms, @user)
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

            it 'contains an array named "counts" of size 1' do
              @symptoms.each do |symptom|
                expect(symptom).to have_key('counts')
                expect(symptom['counts']).to be_an Array
                expect(symptom['counts'].length).to eq 1
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