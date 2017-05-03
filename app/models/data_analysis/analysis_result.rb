class DataAnalysis::AnalysisResult < ActiveRecord::Base
  belongs_to :data_analysis_analysis_users_having_same_symptom, :class_name => 'DataAnalysis::AnalysisUsersHavingSameSymptom'
  has_many :data_analysis_analysis_result_symptoms, :class_name => 'DataAnalysis::AnalysisResultSymptom', foreign_key: :data_analysis_analysis_result_id
  has_many :symptoms, through: :data_analysis_analysis_result_symptoms

  validates_presence_of :result_number
  validates_presence_of :data_analysis_analysis_users_having_same_symptom_id
end
