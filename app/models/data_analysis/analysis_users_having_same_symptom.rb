class DataAnalysis::AnalysisUsersHavingSameSymptom < ActiveRecord::Base
  has_secure_token

  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :threshold
  validates_presence_of :status

  validates_inclusion_of :status, in: %w( created running done aborted dead )
end
