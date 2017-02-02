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
    end
  end
end
