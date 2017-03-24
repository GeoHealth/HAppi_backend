require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:email) }

    it { should validate_presence_of(:expiration_date) }

    it { should validate_presence_of(:user_id) }

    it { should validate_presence_of(:token) }
  end

end
