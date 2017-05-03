class DataAnalysis::AnalysisUsersHavingSameSymptom < DataAnalysis::BasisAnalysis
  has_many :data_analysis_analysis_results, :class_name => 'DataAnalysis::AnalysisResult', foreign_key: :data_analysis_analysis_users_having_same_symptom_id

  validates_presence_of :start_date
  validates_presence_of :end_date
end
