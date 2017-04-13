class DataAnalysis::AnalysisUsersHavingSameSymptomWorker
  include Sidekiq::Worker

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
    # code here
  end

  def delete_input_file(analysis)
    # code here
  end
end
