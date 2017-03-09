require 'rails_helper'

RSpec.describe SymptomsUserController, type: :controller do
  describe '#index' do

    it { should route(:get, '/symptoms_user').to(action: :index) }

    context 'when no user is logged in' do
      it_behaves_like 'GET protected with authentication controller', :index
    end

    context 'when an user is logged in' do

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end


      context 'when the user has no symptom' do

        before(:each) do
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

        it 'returns an empty list of symptoms' do
          expect(JSON.parse(response.body)['symptoms'].length).to eq 0
        end
      end

      context 'when the user has 3 symptoms' do
        subject { JSON.parse(response.body)['symptoms'] }

        before(:each) do
          create_list(:symptoms_user, 3, user_id: @user.id)
        end

        before(:each) do
          get :index
        end

        it 'returns a list of 3 symptoms' do
          expect(subject.length).to eq 3
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

        it 'each symptom is linked to the logged in user' do
          subject.each do |symptom|
            expect(SymptomsUser.where(user_id: @user.id, symptom_id: symptom['id'])).to exist
          end
        end
      end
    end
  end
end
