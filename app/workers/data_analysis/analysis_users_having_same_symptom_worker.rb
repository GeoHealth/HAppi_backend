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
end
