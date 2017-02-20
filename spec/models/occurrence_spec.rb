require 'rails_helper'

RSpec.describe Occurrence, type: :model do

  describe 'attributes' do
    it { should validate_presence_of(:symptom_id) }

    it { should validate_presence_of(:date) }

    it { should validate_presence_of(:user_id) }
  end

  describe '#as_json' do
    context 'when gps_coordinate is defined' do
      before(:each) do
        @occurrence = Occurrence.new(gps_coordinate: GpsCoordinate.new)
      end
      it 'includes the gps_coordinate' do
        expect(@occurrence.as_json['gps_coordinate']).not_to be_nil
      end

      it 'includes the date' do
        expect(@occurrence.as_json).to have_key('date')
      end

      context 'when other options are given' do
        it 'takes other options into account' do
          json = @occurrence.as_json({except: :date})
          expect(json['gps_coordinate']).not_to be_nil
          expect(json).not_to have_key('date')
        end
      end
    end

    context 'when gps_coordinate is not defined' do
      it 'returns a json with a nil value for gps_coordinate' do
        occurrence = Occurrence.new
        expect(occurrence.as_json['gps_coordinate']).to be_nil
      end
    end
  end

end
