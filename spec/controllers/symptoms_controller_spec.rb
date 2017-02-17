require 'rails_helper'

RSpec.describe SymptomsController, type: :controller do
  describe '#index' do
    number_of_symptoms_to_create = 25

    it { should route(:get, '/symptoms').to(action: :index) }

    context 'without valid authentication headers' do
      before(:each) do
        @symptom = create_list(:symptom, number_of_symptoms_to_create)
        get :index
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

      context 'when no parameters are provided' do
        before(:each) do
          @symptom = create_list(:symptom, number_of_symptoms_to_create)
          get :index
        end

        it 'responds with 200' do
          is_expected.to respond_with 200
        end

        it 'returns a JSON containing the key "symptoms"' do
          expect(response.body).to be_instance_of(String)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response).to have_key('symptoms')
        end

        it 'returns a JSON containing all the symptoms' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq Symptom.count
        end

        it 'returns a JSON containing an array of symptoms, each having a name and a gender_filter' do
          parsed_response = JSON.parse(response.body)
          parsed_response['symptoms'].each do |symptom|
            expect(symptom).to have_key 'name'
            expect(symptom).to have_key 'gender_filter'
          end
        end
      end

      context 'when a full symptom name is given as parameter' do
        before(:each) do
          @symptom = create(:symptom)
          @symptom_cold = create(:symptom, name: 'cold')
          get :index, name: 'cold'
        end

        it 'responds with 200' do
          is_expected.to respond_with 200
        end

        it 'returns a JSON containing the key "symptoms"' do
          expect(response.body).to be_instance_of(String)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response).to have_key('symptoms')
        end

        it 'returns a JSON containing all the symptoms matching the given name' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 1
          expect(parsed_response['symptoms'][0]['name']).to eq 'cold'
        end
      end

      context 'when a partial symptom name is given as parameter' do
        before(:each) do
          @symptom = create(:symptom)
          @symptom_cold = create(:symptom, name: 'cold')
          @symptom_cold = create(:symptom, name: 'super cold')
          @symptom_cold = create(:symptom, name: 'cold 42')
          @symptom_cold = create(:symptom, name: 'super cold 42')
          get :index, name: 'col'
        end

        it 'responds with 200' do
          is_expected.to respond_with 200
        end

        it 'returns a JSON containing the key "symptoms"' do
          expect(response.body).to be_instance_of(String)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response).to have_key('symptoms')
        end

        it 'returns a JSON containing all the symptoms matching the partial given name' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 4
        end
      end
    end
  end

  describe '#occurrences' do
    it { should route(:get, '/symptoms/occurrences').to(action: :occurrences) }

    context 'without valid authentication headers' do
      before(:each) do
        get :occurrences
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
            get :occurrences
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
        end

        context 'when there are no occurrence linked to the current user' do
          before(:each) do
            @other_user = create(:user)
            create(:occurrence, symptom_id: @symptom.id, user_id: @other_user.id)
            get :occurrences
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
          get :occurrences
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
