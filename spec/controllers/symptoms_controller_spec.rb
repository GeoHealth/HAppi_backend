require 'rails_helper'

RSpec.shared_examples 'no error occurs' do ||
  it 'responds with 200' do
    is_expected.to respond_with 200
  end

  it 'returns a JSON containing the key "symptoms"' do
    expect(response.body).to be_instance_of(String)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response).to have_key('symptoms')
  end
end

RSpec.describe SymptomsController, type: :controller do
  describe '#index' do

    it { should route(:get, '/symptoms').to(action: :index) }
    it_behaves_like 'GET protected with authentication controller', :index

    context 'with valid authentication headers' do
      unique_name = 'warm'
      names_of_symptoms_to_create = [unique_name, 'cold', 'super cold', 'cold 42', 'super cold 42']
      number_of_symptoms_to_create = names_of_symptoms_to_create.length
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      before(:each) do
        names_of_symptoms_to_create.each { |name| create(:symptom, name: name) }
      end

      context 'when no parameters are provided' do
        before(:each) do
          get :index
        end

        include_examples 'no error occurs'

        describe 'the response' do
          subject { JSON.parse(response.body)['symptoms'] }

          it 'contains all the symptoms' do
            expect(subject.length).to eq number_of_symptoms_to_create
          end

          it 'each symptom has an id, a name, a short_description, a long_description and a gender_filter' do
            subject.each do |symptom|
              expect(symptom).to have_key 'id'
              expect(symptom).to have_key 'name'
              expect(symptom).to have_key 'short_description'
              expect(symptom).to have_key 'long_description'
              expect(symptom).to have_key 'gender_filter'
            end
          end
        end
      end

      context 'when a full symptom name is given as parameter' do
        before(:each) do
          get :index, name: unique_name
        end

        include_examples 'no error occurs'

        it 'returns a JSON containing only the symptom matching the given name' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 1
          expect(parsed_response['symptoms'][0]['name']).to eq unique_name
        end
      end

      context 'when a partial symptom name is given as parameter' do
        before(:each) do
          get :index, name: 'col'
        end

        include_examples 'no error occurs'

        it 'returns a JSON containing all the symptoms matching the partial given name' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 4
        end
      end

      context 'when an unknown name is given as parameter' do
        before(:each) do
          get :index, name: 'anything'
        end

        include_examples 'no error occurs'

        it 'returns a JSON containing no symptoms' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 0
        end
      end

      context 'when a partial bad_key_name is given as parameter' do
        before(:each) do
          get :index, bad_key_name: 'super'
        end

        include_examples 'no error occurs'

        it 'returns a JSON containing all symptoms' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 5
        end
      end

      context 'when a full symptom name containing spaces before and after itself is given' do
        before(:each) do
          get :index, name: '   ' + unique_name + '   '
        end

        include_examples 'no error occurs'

        it 'returns a JSON containing only the symptom matching the given name' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptoms'].length).to eq 1
          expect(parsed_response['symptoms'][0]['name']).to eq unique_name
        end
      end
    end
  end

describe '#occurrences' do
  it { should route(:get, '/symptoms/occurrences').to(action: :occurrences) }
  it_behaves_like 'GET protected with authentication controller', :occurrences

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
