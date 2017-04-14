class DataAnalysis::AnalysisUsersHavingSameSymptomWorker
  include Sidekiq::Worker

  @@bin_lcm_path = './data-analysis-fimi03'

  def perform(analysis_id)
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.find analysis_id
    input_path = create_input_file(@analysis)
    generate_input_file @analysis, input_path
    output_path = "./data-analysis-fimi03/outputs/#{@analysis.token}.output"
    if system "#{@@bin_lcm_path}/fim_closed #{input_path} #{@analysis.threshold} #{output_path}"
      @analysis.status = 'done'
    else
      @analysis.status = 'dead'
    end
    delete_input_file input_path
    @analysis.save
  end

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


  def get_occurrences_matching_analysis(analysis)
    Occurrence
        .select('DISTINCT user_id, symptom_id')
        .where('date BETWEEN :start_date AND :end_date',
               {start_date: analysis.start_date, end_date: analysis.end_date})
        .order(:user_id)
  end

  def delete_input_file(input_file_path)
    system("rm #{input_file_path}")
  end

  private
  def create_input_file(analysis)
    input_path = "#{@@bin_lcm_path}/inputs/#{analysis.token}.input"
    system "touch #{input_path}"
    input_path
  end
end
