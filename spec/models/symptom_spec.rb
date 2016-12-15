require 'rails_helper'

RSpec.describe Symptom, type: :model do

  describe 'attributes' do
    it 'has a name' do
      should validate_presence_of(:name)
    end

    it 'has a gender filter that is either "male", "female" or "both"' do
      should validate_inclusion_of(:gender_filter).
          in_array(%w(male female both))
    end
  end


end
