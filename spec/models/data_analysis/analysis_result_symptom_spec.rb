require 'rails_helper'

RSpec.describe DataAnalysis::AnalysisResultSymptom, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:data_analysis_analysis_result_id) }
    it { should validate_presence_of(:symptom_id) }
  end
end
