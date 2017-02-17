require 'rails_helper'

RSpec.describe OccurrencesController, type: :controller do
  describe '#create' do
    it { should route(:post, '/occurrences').to(action: :create) }
    it_behaves_like 'POST protected with authentication controller', :create, occurrence: @valid_occurrence.to_json

    context 'with valid authentication headers' do
      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when a valid, basic (no gps_location, no factors) occurrence is given' do

        before(:each) do
          @valid_occurrence = build(:occurrence)
          @created_occurrence = post :create, occurrence: @valid_occurrence.to_json
        end

        it 'responds with 201' do
          is_expected.to respond_with 201
        end

        it 'adds the occurrence in the database' do
          expect(Occurrence.count).to eq 1
        end

        it 'returns a JSON containing the occurrence that has been saved' do
          expect(response.body).to be_instance_of(String)
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['symptom_id']).to eq @valid_occurrence.symptom_id
          expect(parsed_response['date']).to eq @valid_occurrence.date
        end

        it 'returns a JSON containing the generated ID' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['id']).not_to be_nil
        end

        it 'is associated to the logged in user' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['user_id']).to eq @user.id
        end
      end

      context 'when no occurrence is given' do
        before(:each) do
          post :create
        end

        it 'responds with 422' do
          is_expected.to respond_with 422
        end

        it 'does not add any occurrence' do
          expect(Occurrence.count).to eq 0
        end
      end

      context 'when the given occurrence reference a non existing symptom' do
        before(:each) do
          @occurrence = build(:occurrence_with_non_existing_symptom)
          post :create, occurrence: @occurrence.to_json
        end

        it 'responds with 422' do
          is_expected.to respond_with 422
        end

        it 'does not add any occurrence' do
          expect(Occurrence.count).to eq 0
        end
      end

      context 'when a valid occurrence with gps_location is given' do
        before(:each) do
          @valid_occurrence = build(:occurrence_with_gps_coordinates)
          post :create, occurrence: @valid_occurrence.to_json(include: :gps_coordinate)
        end

        it 'responds with 201' do
          is_expected.to respond_with 201
        end

        it 'adds the occurrence in the database' do
          expect(Occurrence.count).to eq 1
        end

        it 'adds the gps_coordinate in the database' do
          expect(GpsCoordinate.count).to eq 1
        end

        it 'returns a JSON containing the occurrence that has been saved including the gps_coordinate' do
          expect(response.body).to be_instance_of(String)
          parsed_response = JSON.parse(response.body)

          expect(parsed_response['symptom_id']).to eq @valid_occurrence.symptom_id
          expect(parsed_response['date']).to eq @valid_occurrence.date

          expect(parsed_response['gps_coordinate']).not_to be_nil
          expect(parsed_response['gps_coordinate']['latitude']).to eq @valid_occurrence.gps_coordinate.latitude
          expect(parsed_response['gps_coordinate']['longitude']).to eq @valid_occurrence.gps_coordinate.longitude
          expect(parsed_response['gps_coordinate']['altitude']).to eq @valid_occurrence.gps_coordinate.altitude
        end

        it 'returns a JSON containing the generated ID of occurrence and gps_coordinate' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['id']).not_to be_nil
          expect(parsed_response['gps_coordinate']['id']).not_to be_nil
        end

        it 'is associated to the logged in user' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['user_id']).to eq @user.id
        end
      end
    end
  end
end
