require 'rails_helper'

RSpec.describe DataAnalysis::AnalysisUsersHavingSameSymptom, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
  end
end