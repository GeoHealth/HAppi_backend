class DataAnalysis::AnalysisResultSymptom < ActiveRecord::Base
  belongs_to :data_analysis_analysis_result, :class_name => 'DataAnalysis::AnalysisResult'
  belongs_to :symptom

  validates_presence_of :data_analysis_analysis_result_id
  validates_presence_of :symptom_id
end
