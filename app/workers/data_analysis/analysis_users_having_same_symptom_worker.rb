class DataAnalysis::AnalysisUsersHavingSameSymptomWorker < DataAnalysis::BasisLCMAnalysisWorker

  def generate_input_file(analysis, input_path)
    occurrences = get_occurrences_matching_analysis analysis

    current_user_id = nil
    current_line = ''
    occurrences.each do |occurrence|
      if current_user_id == occurrence.user_id
        current_line = current_line + ' ' unless current_line == ''
        current_line = current_line + occurrence.symptom_id.to_s
      else
        system("echo '#{current_line}' >> #{input_path}") unless current_user_id.nil?
        current_user_id = occurrence.user_id
        current_line = occurrence.symptom_id.to_s
      end
    end
    system("echo '#{current_line}' >> #{input_path}")
  end

  def retrieve_analysis_from_id(analysis_id)
    DataAnalysis::AnalysisUsersHavingSameSymptom.find(analysis_id)
  end

  def get_occurrences_matching_analysis(analysis)
    Occurrence
        .select('DISTINCT user_id, symptom_id')
        .where('date BETWEEN :start_date AND :end_date',
               {start_date: analysis.start_date, end_date: analysis.end_date})
        .order(:user_id)
  end

  def parse_and_store_analysis_results(analysis, output_path)
    file = File.open(output_path)
    file.each_line do |line|
      number_of_match = line.scan(/.*\((\d+)/).last.first
      symptoms = []
      line.scan(/(\d+)\s/).each do |match|
        symptoms << Symptom.find(match.first)
      end
      result = DataAnalysis::AnalysisResult.new(data_analysis_analysis_users_having_same_symptom_id: analysis.id)
      result.result_number = number_of_match
      result.save # save it first because we need its ID to be able to set the join at next line
      result.symptoms << symptoms
      result.save
    end
    file.close
  end
end
