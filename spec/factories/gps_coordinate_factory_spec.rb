require 'rails_helper'

RSpec.describe GpsCoordinateFactory do

  def check_all_attributes
    expect(@received_gps_coordinate.accuracy).to eq(@valid_gps_coordinate[:accuracy])
    expect(@received_gps_coordinate.altitude).to eq(@valid_gps_coordinate[:altitude])
    expect(@received_gps_coordinate.altitude_accuracy).to eq(@valid_gps_coordinate[:altitude_accuracy])
    expect(@received_gps_coordinate.heading).to eq(@valid_gps_coordinate[:heading])
    expect(@received_gps_coordinate.speed).to eq(@valid_gps_coordinate[:speed])
    expect(@received_gps_coordinate.latitude).to eq(@valid_gps_coordinate[:latitude])
    expect(@received_gps_coordinate.longitude).to eq(@valid_gps_coordinate[:longitude])
  end

  def check_all_attributes_are_nil
    expect(@received_gps_coordinate.accuracy).to be_nil
    expect(@received_gps_coordinate.altitude).to be_nil
    expect(@received_gps_coordinate.altitude_accuracy).to be_nil
    expect(@received_gps_coordinate.heading).to be_nil
    expect(@received_gps_coordinate.speed).to be_nil
    expect(@received_gps_coordinate.latitude).to be_nil
    expect(@received_gps_coordinate.longitude).to be_nil
  end

  describe '.build_from_params' do
    context 'when a valid json is given' do
      before(:each) do
        @valid_gps_coordinate = {
            accuracy: 10,
            altitude: 100,
            altitude_accuracy: 1,
            heading: 5,
            speed: 0,
            latitude: 50,
            longitude: 4
        }
        @received_gps_coordinate = GpsCoordinateFactory.build_from_params(@valid_gps_coordinate.as_json)
      end

      it 'returns an instance of GPSCoordinate' do
        expect(@received_gps_coordinate).to be_an_instance_of(GpsCoordinate)
      end

      it 'returns an instance with all attributes set to the given values' do
        check_all_attributes
      end
    end

    context 'when a valid json is given as a string representation' do
      before(:each) do
        @valid_gps_coordinate = {
            accuracy: 10,
            altitude: 100,
            altitude_accuracy: 1,
            heading: 5,
            speed: 0,
            latitude: 50,
            longitude: 4
        }
        @received_gps_coordinate = GpsCoordinateFactory.build_from_params(@valid_gps_coordinate.to_json)
      end

      it 'returns an instance of GPSCoordinate' do
        expect(@received_gps_coordinate).to be_an_instance_of(GpsCoordinate)
      end

      it 'returns an instance with all attributes set to the given values' do
        check_all_attributes
      end
    end

    context 'when a nil value is given' do
      before(:each) do
        @received_gps_coordinate = GpsCoordinateFactory.build_from_params(nil)
      end

      it 'returns an instance of GPSCoordinate' do
        expect(@received_gps_coordinate).to be_an_instance_of(GpsCoordinate)
      end

      it 'returns an instance with all attributes set to nil' do
        check_all_attributes_are_nil
      end
    end

    context 'when an invalid json is given' do
      before(:each) do
        @invalid_gps_coordinate = {
            invalid_key: 5
        }
        @received_gps_coordinate = GpsCoordinateFactory.build_from_params(@invalid_gps_coordinate.as_json)
      end

      it 'returns an instance of GPSCoordinate' do
        expect(@received_gps_coordinate).to be_an_instance_of(GpsCoordinate)
      end

      it 'returns an instance with all attributes set to nil' do
        check_all_attributes_are_nil
      end
    end

    context 'when an invalid json is given as string' do
      before(:each) do
        @invalid_gps_coordinate = {
            invalid_key: 5
        }
        @received_gps_coordinate = GpsCoordinateFactory.build_from_params(@invalid_gps_coordinate.to_json)
      end

      it 'returns an instance of GPSCoordinate' do
        expect(@received_gps_coordinate).to be_an_instance_of(GpsCoordinate)
      end

      it 'returns an instance with all attributes set to nil' do
        check_all_attributes_are_nil
      end
    end
  end
end
