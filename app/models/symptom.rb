class Symptom < ActiveRecord::Base
  has_many :occurrences
  has_many :data_analysis_analysis_result_symptoms, :class_name => 'DataAnalysis::AnalysisResultSymptom'
  has_many :data_analysis_analysis_results, :class_name => 'DataAnalysis::AnalysisResult', through: :data_analysis_analysis_result_symptoms

  validates_presence_of :name
  validates_inclusion_of :gender_filter, in: %w( male female both )
end
