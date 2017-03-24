require 'rails_helper'

RSpec.describe Factor, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:name) }

    it { should validate_presence_of(:factor_type) }
  end
end
