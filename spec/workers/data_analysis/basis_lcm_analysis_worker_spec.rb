require 'rails_helper'
RSpec.describe DataAnalysis::BasisLCMAnalysisWorker, type: :worker do
  before(:each) do
    @job = DataAnalysis::BasisLCMAnalysisWorker.new
    @analysis = create(:basis_analysis)
    @input_path = "./data-analysis-fimi03/inputs/#{@analysis.token}.input"
    @output_path = "./data-analysis-fimi03/outputs/#{@analysis.token}.output"
  end

  describe '#perform' do
    before(:each) do
      @system_return = true
      @delete_input_file_return = true

      allow(@job).to receive(:retrieve_analysis_from_id) {@analysis}
      allow(@job).to receive(:create_input_file) {@input_path}
      allow(@job).to receive(:generate_input_file)
      allow(@job).to receive(:system).with("./data-analysis-fimi03/fim_closed #{@input_path} #{@analysis.threshold} #{@output_path}") {@system_return}
      allow(@job).to receive(:delete_input_file) {@delete_input_file_return}
    end

    it 'makes a call to retrieve_analysis_from_id' do
      expect(@job).to receive(:retrieve_analysis_from_id).with(@analysis.id)
      @job.perform @analysis.id
    end

    it 'makes a call to create_input_file' do
      expect(@job).to receive(:create_input_file)
      @job.perform @analysis.id
    end

    it 'makes a call to generate_input_file' do
      expect(@job).to receive(:generate_input_file)
      @job.perform @analysis.id
    end

    it 'makes a call to system with command ./fimi03/fim_closed and args = "./fimi03/fim_closed/inputs/token.input threshold ./fimi03/fim_closed/outputs/token.output"' do
      expect(@job).to receive(:system).with("./data-analysis-fimi03/fim_closed #{@input_path} #{@analysis.threshold} #{@output_path}")
      @job.perform @analysis.id
    end

    it 'makes a call to delete_input_file' do
      expect(@job).to receive(:delete_input_file)
      @job.perform @analysis.id
    end

    context 'when all calls succeed' do
      before(:each) do
        @system_return = true
        @delete_input_file_return = true
      end

      it 'changes the status of the analysis to "done"' do
        @job.perform @analysis.id
        @analysis = DataAnalysis::BasisAnalysis.find(@analysis.id)
        expect(@analysis.status).to eq 'done'
      end
    end

    context 'when all calls succeed except LCM' do
      before(:each) do
        @system_return = false
        @delete_input_file_return = true
      end

      it 'changes the status of the analysis to "dead"' do
        @job.perform @analysis.id
        @analysis = DataAnalysis::BasisAnalysis.find(@analysis.id)
        expect(@analysis.status).to eq 'dead'
      end
    end
  end

  describe '#delete_input_file' do
    before(:each) do
      @input_path = 'foo/bar'
    end

    it 'calls system rm file' do
      expect(@job).to receive(:system).with("rm #{@input_path}").once
      @job.delete_input_file @input_path
    end
  end

  describe '#create_input_file' do
    it 'calls system touch input_file' do
      expect(@job).to receive(:system).with("touch #{@input_path}").once
      @job.create_input_file @analysis
    end

    it 'returns the input path' do
      expect(@job.create_input_file(@analysis)).to eq @input_path
    end
  end

  describe '#retrieve_analysis_from_id' do
    it 'must be implemented by subclasses and raise an error' do
      expect {@job.retrieve_analysis_from_id @analysis.id}.to raise_error(NotImplementedError, 'You must implement method retrieve_analysis_from_id')
    end
  end

  describe '#generate_input_file' do
    it 'must be implemented by subclasses and raise an error' do
      expect {@job.generate_input_file @analysis, @input_path}.to raise_error(NotImplementedError, 'You must implement method generate_input_file')
    end
  end
end
