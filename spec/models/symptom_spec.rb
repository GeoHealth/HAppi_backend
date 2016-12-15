require 'rails_helper'

RSpec.describe Symptom, type: :model do

  describe 'attributes' do
    it {
      should validate_presence_of(:name)
    }

    it {
      should validate_inclusion_of(:gender_filter).
          in_array(%w( male female both ))
    }
  end


end
