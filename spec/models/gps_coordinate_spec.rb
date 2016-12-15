require 'rails_helper'

RSpec.describe GpsCoordinate, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:latitude) }

    it { should validate_presence_of(:longitude) }
  end
end
