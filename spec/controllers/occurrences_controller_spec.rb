require 'rails_helper'

RSpec.shared_examples 'the given occurrence is not valid' do ||
  it 'responds with 422' do
    is_expected.to respond_with 422
  end

  it 'does not add any occurrence' do
    expect(Occurrence.count).to eq 0
  end

  it 'does not returns anything in the body' do
    expect(response.body).to be_empty
  end
end

RSpec.shared_examples 'the given occurrence is valid' do ||
  it 'responds with 201' do
    is_expected.to respond_with 201
  end

  it 'adds the occurrence in the database' do
    expect(Occurrence.count).to eq 1
  end

  it 'returns a JSON' do
    expect(response.body).to be_instance_of(String)
  end

  describe 'the response' do
    subject { JSON.parse(response.body) }

    it 'contains the occurrence that has been saved' do
      expect(subject['symptom_id']).to eq @valid_occurrence.symptom_id
      expect(subject['date']).to eq @valid_occurrence.date
    end

    it 'contains the generated ID' do
      expect(subject['id']).not_to be_nil
    end

    it 'is associated to the logged in user' do
      expect(subject['user_id']).to eq @user.id
    end
  end
end

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
          post :create, occurrence: @valid_occurrence.to_json
        end

        include_examples 'the given occurrence is valid'
      end

      context 'when no occurrence is given' do
        before(:each) do
          post :create
        end

        include_examples 'the given occurrence is not valid'
      end

      context 'when the given occurrence references a non existing symptom' do
        before(:each) do
          @occurrence = build(:occurrence_with_non_existing_symptom)
          post :create, occurrence: @occurrence.to_json
        end

        include_examples 'the given occurrence is not valid'
      end

      context 'when a valid occurrence with gps_location is given' do
        before(:each) do
          @valid_occurrence = build(:occurrence_with_gps_coordinates)
          post :create, occurrence: @valid_occurrence.to_json(include: :gps_coordinate)
        end

        include_examples 'the given occurrence is valid'

        it 'adds the gps_coordinate in the database' do
          expect(GpsCoordinate.count).to eq 1
        end

        describe 'the response' do
          subject { JSON.parse(response.body) }

          it 'contains the occurrence that has been saved including the gps_coordinate' do
            expect(subject['gps_coordinate']).not_to be_nil
            expect(subject['gps_coordinate']['latitude']).to eq @valid_occurrence.gps_coordinate.latitude
            expect(subject['gps_coordinate']['longitude']).to eq @valid_occurrence.gps_coordinate.longitude
            expect(subject['gps_coordinate']['altitude']).to eq @valid_occurrence.gps_coordinate.altitude
          end

          it 'contains the generated ID of gps_coordinate' do
            expect(subject['gps_coordinate']['id']).not_to be_nil
          end
        end
      end
    end
  end
end
