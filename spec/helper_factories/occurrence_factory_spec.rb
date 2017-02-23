require 'rails_helper'

RSpec.describe OccurrenceFactory do

  def check_all_attributes
    expect(@received_occurrence.symptom_id).to eq(@valid_occurrence[:symptom_id])
    expect(@received_occurrence.date).to be_within(1.second).of (Time.zone.parse(@valid_occurrence[:date]))

    expect(@received_occurrence.gps_coordinate.accuracy).to eq(@valid_occurrence[:gps_coordinate][:accuracy])
    expect(@received_occurrence.gps_coordinate.altitude).to eq(@valid_occurrence[:gps_coordinate][:altitude])
    expect(@received_occurrence.gps_coordinate.altitude_accuracy).to eq(@valid_occurrence[:gps_coordinate][:altitude_accuracy])
    expect(@received_occurrence.gps_coordinate.heading).to eq(@valid_occurrence[:gps_coordinate][:heading])
    expect(@received_occurrence.gps_coordinate.speed).to eq(@valid_occurrence[:gps_coordinate][:speed])
    expect(@received_occurrence.gps_coordinate.latitude).to eq(@valid_occurrence[:gps_coordinate][:latitude])
    expect(@received_occurrence.gps_coordinate.longitude).to eq(@valid_occurrence[:gps_coordinate][:longitude])
  end

  def check_all_attributes_are_nil
    expect(@received_occurrence.symptom_id).to be_nil
    expect(@received_occurrence.date).to be_nil
    expect(@received_occurrence.gps_coordinate).to be_nil
  end

  describe '.build_from_params' do
    context 'when a valid json is given' do
      before(:each) do
        @valid_occurrence = {
            symptom_id: 2,
            date: '2016-12-15',
            gps_coordinate: {
                latitude: 50.65,
                longitude: 4.06,
                altitude: 25.2,
                accuracy: 10,
                altitude_accuracy: 10
            }
        }
        @received_occurrence = OccurrenceFactory.build_from_params(@valid_occurrence.as_json)
      end

      it 'returns an instance of Occurrence' do
        expect(@received_occurrence).to be_an_instance_of(Occurrence)
      end

      it 'returns an instance with all attributes set to the given values' do
        check_all_attributes
      end
    end

    context 'when a valid json is given as a string' do
      before(:each) do
        @valid_occurrence = {
            symptom_id: 2,
            date: '2016-12-15 00:00:00',
            gps_coordinate: {
                latitude: 50.65,
                longitude: 4.06,
                altitude: 25.2,
                accuracy: 10,
                altitude_accuracy: 10
            }
        }
        @received_occurrence = OccurrenceFactory.build_from_params(@valid_occurrence.to_json)
      end

      it 'returns an instance of Occurrence' do
        expect(@received_occurrence).to be_an_instance_of(Occurrence)
      end

      it 'returns an instance with all attributes set to the given values' do
        check_all_attributes
      end
    end

    context 'when a nil value is given' do
      before(:each) do
        @received_occurrence = OccurrenceFactory.build_from_params(nil)
      end

      it 'returns an instance of Occurrence' do
        expect(@received_occurrence).to be_an_instance_of(Occurrence)
      end

      it 'returns an occurrence with all attributes set to nil' do
        check_all_attributes_are_nil
      end
    end

    context 'when an invalid json is given' do
      before(:each) do
        @invalid_occurrence = {
            invalid_key: 5
        }
        @received_occurrence = OccurrenceFactory.build_from_params(@invalid_occurrence.as_json)
      end

      it 'returns an instance of Occurrence' do
        expect(@received_occurrence).to be_an_instance_of(Occurrence)
      end

      it 'returns an occurrence with all attributes set to nil' do
        check_all_attributes_are_nil
      end
    end

    context 'when an invalid json is given as string' do
      before(:each) do
        @invalid_occurrence = {
            invalid_key: 5
        }
        @received_occurrence = OccurrenceFactory.build_from_params(@invalid_occurrence.to_json)
      end

      it 'returns an instance of Occurrence' do
        expect(@received_occurrence).to be_an_instance_of(Occurrence)
      end

      it 'returns an occurrence with all attributes set to nil' do
        check_all_attributes_are_nil
      end
    end
  end
end
