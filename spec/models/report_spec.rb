require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:email) }

    it { should validate_presence_of(:expiration_date) }

    it { should validate_presence_of(:user_id) }

    it { should validate_presence_of(:start_date) }

    it { should validate_presence_of(:end_date) }
  end

  describe 'after save' do
    before(:each) do
      @report = build(:report)
      @report.save
    end

    it 'has a generated token' do
      expect(@report.token).not_to be_nil
    end
  end

end
