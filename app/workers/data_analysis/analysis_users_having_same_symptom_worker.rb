class DataAnalysis::AnalysisUsersHavingSameSymptomWorker
  include Sidekiq::Worker

  @@bin_lcm_path = './data-analysis-fimi03'

  def perform(analysis_id)
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.find analysis_id
    create_input_file @analysis
    if system "./data-analysis-fimi03/fim_closed ./data-analysis-fimi03/inputs/#{@analysis.token}.input #{@analysis.threshold} ./data-analysis-fimi03/outputs/#{@analysis.token}.output"
      @analysis.status = 'done'
    else
      @analysis.status = 'dead'
    end
    delete_input_file @analysis
    @analysis.save
  end

  def create_input_file(analysis)
    input_path = "#{@@bin_lcm_path}/inputs/#{analysis.token}.input"
    system("touch #{input_path}")

    occurrences = get_occurrences_matching_analysis analysis


    system("echo content >> #{input_path}")
  end

  def get_occurrences_matching_analysis(analysis)
    Occurrence
        .select('DISTINCT user_id, symptom_id')
        .where('date BETWEEN :start_date AND :end_date',
               {start_date: analysis.start_date, end_date: analysis.end_date})
        .order(:user_id)
  end

  def delete_input_file(analysis)
    # code here
  end
end
