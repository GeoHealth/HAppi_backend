require 'rails_helper'
require_relative '__version__'

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
      expect(Time.zone.parse(subject['date'])).to be_within(1.second).of @valid_occurrence.date
    end

    it 'contains the generated ID' do
      expect(subject['id']).not_to be_nil
    end

    it 'is associated to the logged in user' do
      expect(subject['user_id']).to eq @user.id
    end
  end
end

RSpec.shared_examples 'no error occurs and the key occurrences is present' do ||
  it 'responds with 200' do
    is_expected.to respond_with 200
  end

  it 'returns a JSON containing the key "occurrences"' do
    expect(response.body).to be_instance_of(String)
    parsed_response = JSON.parse(response.body)
    expect(parsed_response).to have_key('occurrences')
  end
end

RSpec.shared_examples 'status 422 and one occurrence' do
  it 'responds with status 422' do
    is_expected.to respond_with 422
  end

  it 'does not delete the occurrence' do
    expect(Occurrence.count).to eq 1
  end
end

RSpec.describe  V1::OccurrencesController, type: :controller do
  describe '#create' do
    it { should route(:post, @version + '/occurrences').to(action: :create) }
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

        it 'does not call a weather job' do
          expect(WeatherFactorInstancesWorker.jobs.size).to eq 0
        end
      end

      context 'when no occurrence is given' do
        before(:each) do
          post :create
        end

        include_examples 'the given occurrence is not valid'

        it 'does not call a weather job' do
          expect(WeatherFactorInstancesWorker.jobs.size).to eq 0
        end
      end

      context 'when the given occurrence references a non existing symptom' do
        before(:each) do
          @occurrence = build(:occurrence_with_non_existing_symptom)
          post :create, occurrence: @occurrence.to_json
        end

        include_examples 'the given occurrence is not valid'

        it 'does not call a weather job' do
          expect(WeatherFactorInstancesWorker.jobs.size).to eq 0
        end
      end

      context 'when a valid occurrence with gps_location is given' do
        before(:each) do
          @valid_occurrence = build(:occurrence_with_gps_coordinates)
          post :create, occurrence: @valid_occurrence.to_json(include: :gps_coordinate)
        end

        include_examples 'the given occurrence is valid'

        it 'calls a weather job' do
          expect(WeatherFactorInstancesWorker.jobs.size).to eq 1
        end

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

  describe '#index' do
    it { should route(:get, @version + '/occurrences').to(action: :index) }

    context 'when no user is logged in' do
      it_behaves_like 'GET protected with authentication controller', :create
    end

    context 'with valid authentication headers' do

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end


      context 'when the user has not added an occurrence' do

        before(:each) do
          get :index
        end

        include_examples 'no error occurs and the key occurrences is present'

        it 'returns no occurrence' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['occurrences'].length).to eq 0
        end

      end

      context 'when the user has added an occurrence' do

        before(:each) do
          @valid_occurrence = create(:occurrence, user_id: @user.id)
        end

        before(:each) do
          get :index
        end

        include_examples 'no error occurs and the key occurrences is present'

        it 'returns one occurrence' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['occurrences'].length).to eq 1
        end

        it 'returns one occurrence with its symptom' do
          subject = JSON.parse(response.body)['occurrences']
          subject.each do |occurrence|
            expect(occurrence).to have_key 'symptom'
          end
        end
      end

      context 'when the user has added ten occurrences' do

        before(:each) do
          @valid_occurrence = create_list(:occurrence, 10, user_id: @user.id)
        end

        before(:each) do
          get :index
        end

        include_examples 'no error occurs and the key occurrences is present'

        it 'returns ten occurrences' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['occurrences'].length).to eq 10
        end

        context 'when an other user added also ten occurrences' do

          before(:each) do
            @valid_occurrence = create_list(:occurrence, 10)
          end

          before(:each) do
            get :index
          end

          it 'returns ten occurrences' do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response['occurrences'].length).to eq 10
          end

        end

      end

    end
  end
  describe '#destroy' do
    it { should route(:delete, @version + '/occurrences').to(action: :destroy) }

    context 'when no user is logged in' do
      it_behaves_like 'DELETE protected with authentication controller', :destroy
    end

    context 'when an user is logged in' do

      before(:each) do
        @user = AuthenticationTestHelper.set_valid_authentication_headers(@request)
        sign_in @user
      end

      context 'when the occurrence is in the database'do
        before(:each) do
          @valid_occurrence = create(:occurrence, user_id: @user.id)
        end

        context 'when the occurrence id is valid' do
          before(:each) do
            delete :destroy, occurrence_id: @valid_occurrence.id
          end

          it 'responds with status 200' do
            is_expected.to respond_with 200
          end

          it 'deletes the occurrence' do
            expect(Occurrence.count).to eq 0
          end

          it 'returns the destroy object' do
            expect(JSON.parse(response.body)['user_id']).to eq @user.id
            expect(JSON.parse(response.body)['id']).to eq @valid_occurrence.id
          end
        end

        context 'when the given occurrence id is not valid or' do
          before(:each) do
            delete :destroy, symptom_id: -1
          end

          include_examples 'status 422 and one occurrence'

        end
      end
    end
  end
end
