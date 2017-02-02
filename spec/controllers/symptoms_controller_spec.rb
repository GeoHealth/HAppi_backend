require 'rails_helper'

RSpec.describe SymptomsController, type: :controller do
  describe '#index' do
    it { should route(:get, '/symptoms').to(action: :index) }

    context 'when no parameters are provided' do
      number_of_symptoms_to_create = 25

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
