require 'rails_helper'

RSpec.describe Occurrence, type: :model do

  describe 'attributes' do
    it { should validate_presence_of(:symptom_id) }

    it { should validate_presence_of(:date) }
  end

end
