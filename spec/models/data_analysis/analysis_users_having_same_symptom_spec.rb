require 'rails_helper'

RSpec.describe DataAnalysis::AnalysisUsersHavingSameSymptom, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }

    it 'can be associated to 2 instances of DataAnalysis::AnalysisResult' do
      analysis = create(:analysis_users_having_same_symptom)
      analysis_results = create_list(:analysis_results, 2, data_analysis_analysis_users_having_same_symptom_id: analysis.id)
      analysis.data_analysis_analysis_results << analysis_results

      expect{analysis.save}.not_to raise_exception
      expect(analysis.data_analysis_analysis_results.length).to eq 2
    end
  end
end