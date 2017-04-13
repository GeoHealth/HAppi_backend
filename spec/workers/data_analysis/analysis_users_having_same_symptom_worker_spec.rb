require 'rails_helper'
RSpec.describe DataAnalysis::AnalysisUsersHavingSameSymptomWorker, type: :worker do
  before(:each) do
    @job = DataAnalysis::AnalysisUsersHavingSameSymptomWorker.new
    @analysis = create(:analysis_users_having_same_symptom)
  end

  describe '#perform' do
    before(:each) do
      @create_input_file_return = true
      @system_return = true
      @delete_input_file_return = true

      allow(@job).to receive(:create_input_file) { @create_input_file_return }
      allow(@job).to receive(:system).with("./data-analysis-fimi03/fim_closed ./data-analysis-fimi03/inputs/#{@analysis.token}.input #{@analysis.threshold} ./data-analysis-fimi03/outputs/#{@analysis.token}.output") { @system_return }
      allow(@job).to receive(:delete_input_file) { @delete_input_file_return }
    end

    it 'makes a call to create_input_file' do
      expect(@job).to receive(:create_input_file)
      @job.perform @analysis.id
    end

    it 'makes a call to system with command ./fimi03/fim_closed and args = "./fimi03/fim_closed/inputs/token.input threshold ./fimi03/fim_closed/outputs/token.output"' do
      expect(@job).to receive(:system).with("./data-analysis-fimi03/fim_closed ./data-analysis-fimi03/inputs/#{@analysis.token}.input #{@analysis.threshold} ./data-analysis-fimi03/outputs/#{@analysis.token}.output")
      @job.perform @analysis.id
    end

    it 'makes a call to delete_input_file' do
      expect(@job).to receive(:delete_input_file)
      @job.perform @analysis.id
    end

    context 'when all calls succeed' do
      before(:each) do
        @create_input_file_return = true
        @system_return = true
        @delete_input_file_return = true
      end

      it 'changes the status of the analysis to "done"' do
        @job.perform @analysis.id
        @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.find(@analysis.id)
        expect(@analysis.status).to eq 'done'
      end
    end

    context 'when all calls succeed except system' do
      before(:each) do
        @create_input_file_return = true
        @system_return = false
        @delete_input_file_return = true
      end

      it 'changes the status of the analysis to "dead"' do
        @job.perform @analysis.id
        @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.find(@analysis.id)
        expect(@analysis.status).to eq 'dead'
      end
    end
  end

  describe '#create_input_file' do
    context 'when there are 5 users in the database having 3 symptoms between the start_date and end_date of the report' do
      before(:each) do

      end

      it 'creates a file containing' do

      end
    end
  end
end
