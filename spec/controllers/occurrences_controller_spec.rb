require 'rails_helper'

RSpec.describe OccurrencesController, type: :controller do
  describe '#create' do
    it { should route(:post, '/occurrences').to(action: :create) }

    context 'when a valid, basic (no gps_location, no factors) occurrence is given' do

      before(:each) do
        @valid_symptom = Symptom.new(id: 1, name: 'the_symptom', gender_filter: 'both')
        @valid_symptom.save
        @valid_occurrence = Occurrence.new(symptom_id: @valid_symptom.id, date: Date.new)
        post :create, @valid_occurrence.as_json
      end

      it 'responds with 200' do
        should respond_with 200
      end

      it 'adds the occurrence in the database' do
        expect(Occurrence.count).to eq 1
      end
    end

    context 'when no occurrence is given' do
      before(:each) do
        post :create
      end

      it 'responds with 422' do
        should respond_with 422
      end

      it 'does not add any occurrence' do
        expect(Occurrence.count).to eq 0
      end
    end

    context 'when the given occurrence reference a non existing symptom' do
      before(:each) do
        @valid_symptom = Symptom.new(id: 1, name: 'the_symptom', gender_filter: 'both')
        @valid_occurrence = Occurrence.new(symptom_id: @valid_symptom.id, date: Date.new)
        post :create, @valid_occurrence.as_json
      end

      it 'responds with 404' do
        should respond_with 404
      end

      it 'does not add any occurrence' do
        expect(Occurrence.count).to eq 0
      end
    end

    context 'when a valid occurrence with gps_location is given' do
      before(:each) do
        @valid_symptom = Symptom.new(id: 1, name: 'the_symptom', gender_filter: 'both')
        @valid_symptom.save

        @gps_location = GpsCoordinate.new(latitude: 50.663856999985, longitude: 4.6251496, altitude: 25.3)

        @valid_occurrence = Occurrence.new(symptom_id: @valid_symptom.id, date: Date.new, gps_coordinate: @gps_location)
        post :create, @valid_occurrence.as_json( include: :gps_coordinate)
      end

      it 'responds with 200' do
        should respond_with 200
      end

      it 'adds the occurrence in the database' do
        expect(Occurrence.count).to eq 1
      end

      it 'adds the gps_coordinate in the database' do
        expect(GpsCoordinate.count).to eq 1
      end

    end

  end

end
