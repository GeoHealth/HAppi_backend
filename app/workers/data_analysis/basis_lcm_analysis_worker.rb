class DataAnalysis::BasisLCMAnalysisWorker
  include Sidekiq::Worker

  @@bin_lcm_path = './data-analysis-fimi03'

  def perform(analysis_id)
    @analysis = retrieve_analysis_from_id(analysis_id)
    chmod_x_fim_closed
    input_path = create_input_file(@analysis)
    generate_input_file @analysis, input_path
    output_path = "#{@@bin_lcm_path}/outputs/#{@analysis.token}.output"
    if system "#{@@bin_lcm_path}/fim_closed #{input_path} #{@analysis.threshold} #{output_path}"
      @analysis.status = 'done'
    else
      @analysis.status = 'dead'
    end
    delete_input_file input_path
    @analysis.save
  end

  def chmod_x_fim_closed
    system "chmod +x #{@@bin_lcm_path}/fim_closed";
  end

  def delete_input_file(input_file_path)
    system("rm #{input_file_path}")
  end

  def create_input_file(analysis)
    input_path = "#{@@bin_lcm_path}/inputs/#{analysis.token}.input"
    system "touch #{input_path}"
    input_path
  end

  def retrieve_analysis_from_id(analysis_id)
    fail NotImplementedError, 'You must implement method retrieve_analysis_from_id'
  end

  def generate_input_file(analysis, input_path)
    fail NotImplementedError, 'You must implement method generate_input_file'
  end
end
