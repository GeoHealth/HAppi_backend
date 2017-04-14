class DataAnalysis::AnalysisUsersHavingSameSymptom < DataAnalysis::BasisAnalysis
  validates_presence_of :start_date
  validates_presence_of :end_date
end
