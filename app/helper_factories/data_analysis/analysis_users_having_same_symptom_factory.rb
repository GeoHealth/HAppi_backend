class DataAnalysis::AnalysisUsersHavingSameSymptomFactory
  def self.build_from_params(json_analysis)
    json_analysis = JSON.parse(json_analysis) if json_analysis.class.equal?(String)

    analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.new
    if json_analysis

      start_date = json_analysis.fetch('start_date', "#{json_analysis['start_date(1i)']}-#{json_analysis['start_date(2i)']}-#{json_analysis['start_date(3i)']} #{json_analysis['start_date(4i)']}:#{json_analysis['start_date(5i)']}")
      end_date = json_analysis.fetch('end_date', "#{json_analysis['end_date(1i)']}-#{json_analysis['end_date(2i)']}-#{json_analysis['end_date(3i)']} #{json_analysis['end_date(4i)']}:#{json_analysis['end_date(5i)']}")
      analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.new start_date: start_date,
                                                                  end_date: end_date,
                                                                  threshold: json_analysis.fetch('threshold', nil),
                                                                  status: 'created'
    end
    analysis
  end
end