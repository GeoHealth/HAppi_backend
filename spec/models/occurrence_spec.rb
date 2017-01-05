require 'rails_helper'

RSpec.describe Occurrence, type: :model do

  describe 'attributes' do
    it { should validate_presence_of(:symptom_id) }

    it { should validate_presence_of(:date) }
  end

  describe '#as_json' do
    context 'when gps_coordinate is defined' do
      it 'includes the gps_coordinate' do
        occurrence = Occurrence.new(gps_coordinate: GpsCoordinate.new)
        expect(occurrence.as_json['gps_coordinate']).not_to be_nil
      end
    end
  end

end
