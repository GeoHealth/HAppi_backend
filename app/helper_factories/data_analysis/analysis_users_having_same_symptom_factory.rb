class DataAnalysis::AnalysisUsersHavingSameSymptomFactory
  def self.build_from_params(json_analysis)
    json_analysis = JSON.parse(json_analysis) if json_analysis.class.equal?(String)

    analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.new
    if json_analysis
      analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.new start_date: json_analysis.fetch('start_date', nil),
                                                    end_date: json_analysis.fetch('end_date', nil),
                                                    threshold: json_analysis.fetch('threshold', nil),
                                                    status: 'created'
    end
    analysis
  end
end