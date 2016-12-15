require 'rails_helper'

RSpec.describe FactorInstance, type: :model do

  describe 'attributes' do
    it { should validate_presence_of(:factor_id) }

    it { should validate_presence_of(:value) }
  end
end
