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

  describe '#create' do
    it { should route(:post, '/symptoms_user').to(action: :create) }

    context 'when no user is logged in' do
      it_behaves_like 'POST protected with authentication controller', :create
    end

    context 'when an user is logged in' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when the given symptom_id is correct' do
        before(:each) do
          @valid_symptoms_user = build(:symptoms_user, user_id: @user.id)
          post :create, symptom_id: @valid_symptoms_user.symptom_id
        end

        it 'responds with status 200' do
          is_expected.to respond_with 200
        end

        it 'adds a symptoms_user to the database with the correct symptom_id and the user_id of the logged in user' do
          expect(SymptomsUser.count).to eq 1
          expect(SymptomsUser.first.user_id).to eq @user.id
          expect(SymptomsUser.first.symptom_id).to eq @valid_symptoms_user.symptom_id
        end

        it 'returns the created object' do
          expect(JSON.parse(response.body)['user_id']).to eq @user.id
          expect(JSON.parse(response.body)['symptom_id']).to eq @valid_symptoms_user.symptom_id
        end
      end

      context 'when the symptom_id is invalid' do
        before(:each) do
          @valid_symptoms_user = build(:symptoms_user)
          post :create, symptom_id: -1
        end

        it 'responds with status 422' do
          is_expected.to respond_with 422
        end
      end

      context 'when the symptom_id key is not present' do
        before(:each) do
          @valid_symptoms_user = build(:symptoms_user)
          post :create, foo: nil
        end

        it 'responds with status 422' do
          is_expected.to respond_with 422
        end
      end

      context 'when the symptom_id already exists for the user' do
        before(:each) do
          @valid_symptoms_user = create(:symptoms_user, user_id: @user.id)
          post :create, symptom_id: @valid_symptoms_user.symptom_id
        end

        it 'responds with status 422' do
          is_expected.to respond_with 422
        end
      end
    end
  end

  describe '#delete' do
    it { should route(:delete, '/symptoms_user').to(action: :destroy) }

    context 'when no user is logged in' do
      it_behaves_like 'DELETE protected with authentication controller', :destroy
    end

    context 'when an user is logged in' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when the symptom is in the database' do
        before(:each) do
          @valid_symptoms_user = create(:symptoms_user, user_id: @user.id)
        end

        context 'when the given symptom id is valide' do
          before(:each) do
            delete :destroy, symptom_id: @valid_symptoms_user.symptom_id
          end

          it 'responds with status 200' do
            is_expected.to respond_with 200
          end

          it 'deletes the symptom' do
            expect(SymptomsUser.count).to eq 0
          end

          it 'returns the destroy object' do
            expect(JSON.parse(response.body)['user_id']).to eq @user.id
            expect(JSON.parse(response.body)['symptom_id']).to eq @valid_symptoms_user.symptom_id
          end
        end

        context 'when the given symptom id is not valide' do
          before(:each) do
            delete :destroy, symptom_id: -1
          end

          it 'responds with status 422' do
            is_expected.to respond_with 422
          end

          it 'does not delete the symptom' do
            expect(SymptomsUser.count).to eq 1
          end

        end

        context 'when the symptom id is not given' do
          before(:each) do
            delete :destroy
          end

          it 'responds with status 422' do
            is_expected.to respond_with 422
          end

          it 'does not delete the symptom' do
            expect(SymptomsUser.count).to eq 1
          end

        end

      end

    end

  end
end
