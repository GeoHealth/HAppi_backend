require 'rails_helper'

RSpec.describe DataAnalysis::AnalysisResult, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:result_number) }
    it { should validate_presence_of(:data_analysis_analysis_users_having_same_symptom_id) }
  end

  describe 'has many symptoms through DataAnalysis::AnalysisResultSymptom' do
    it 'can be associated to 2 symptoms' do
      analysis_result = create(:analysis_results)
      symptoms = create_list(:symptom, 2)
      analysis_result.symptoms << symptoms
      expect{analysis_result.save}.not_to raise_exception
      expect(analysis_result.symptoms.length).to eq 2
    end
  end
end
