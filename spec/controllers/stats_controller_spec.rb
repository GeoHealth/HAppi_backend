require 'rails_helper'
require 'authentication_test_helper'

RSpec.describe StatsController, type: :controller do
  describe '#symptoms' do
    it { should route(:get, '/stats/symptoms').to(action: :symptoms) }

    context 'without valid authentication headers' do
      before(:each) do
        get :symptoms
      end

      it 'responds with 401' do
        is_expected.to respond_with 401
      end
    end

    context 'with valid authentication headers' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when there is one symptom' do
        before(:each) do
          @symptom = create(:symptom)
        end

        context 'when there are occurrences linked to the current user' do
          number_of_occurrences = 10
          before(:each) do
            create_list(:occurrence, number_of_occurrences, symptom_id: @symptom.id, user_id: @user.id)
            get :symptoms
          end

          it 'responds with code 200' do
            is_expected.to respond_with 200
          end

          it 'returns a JSON containing an array of one symptom with the occurrences' do
            expect(response.body).to be_instance_of(String)
            parsed_response = JSON.parse(response.body)
            expect(parsed_response).to have_key('symptoms')

            symptoms = parsed_response['symptoms']
            expect(symptoms).to be_an Array
            expect(symptoms.length).to eq 1

            symptom = symptoms[0]
            expect(symptom).to have_key('occurrences')
            expect(symptom['occurrences']).to be_an Array

            occurrences = symptom['occurrences']
            expect(occurrences.length).to eq number_of_occurrences
          end

          it 'does not include useless attribute :short_description, :long_description, :category, :gender_filter' do
            symptom = JSON.parse(response.body)['symptoms'][0]
            expect(symptom).not_to have_key('short_description')
            expect(symptom).not_to have_key('long_description')
            expect(symptom).not_to have_key('category')
            expect(symptom).not_to have_key('gender_filter')
          end
        end

        context 'when there are no occurrence linked to the current user' do
          before(:each) do
            @other_user = create(:user)
            create(:occurrence, symptom_id: @symptom.id, user_id: @other_user.id)
            get :symptoms
          end

          it 'responds with code 200' do
            is_expected.to respond_with 200
          end

          it 'returns and empty array of symptoms' do
            expect(response.body).to be_instance_of(String)
            parsed_response = JSON.parse(response.body)
            expect(parsed_response).to have_key('symptoms')
            expect(parsed_response['symptoms'].length).to eq 0
          end
        end
      end

      context 'when there are no symptom' do
        before(:each) do
          get :symptoms
        end

        it 'responds with code 200' do
          is_expected.to respond_with 200
        end

        it 'returns and empty array of symptoms' do
          expect(response.body).to be_instance_of(String)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response).to have_key('symptoms')
          expect(parsed_response['symptoms'].length).to eq 0
        end
      end
    end
  end
end