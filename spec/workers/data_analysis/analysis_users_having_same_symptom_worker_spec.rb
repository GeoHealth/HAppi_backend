require 'rails_helper'
RSpec.describe DataAnalysis::AnalysisUsersHavingSameSymptomWorker, type: :worker do
  before(:each) do
    @job = DataAnalysis::AnalysisUsersHavingSameSymptomWorker.new
    @analysis = create(:analysis_users_having_same_symptom)
  end

  describe '#perform' do
    before(:each) do
      @create_input_file_return = "./data-analysis-fimi03/inputs/#{@analysis.token}.input"
      @system_return = true
      @delete_input_file_return = true

      allow(@job).to receive(:create_input_file) {@create_input_file_return}
      allow(@job).to receive(:system).with("./data-analysis-fimi03/fim_closed ./data-analysis-fimi03/inputs/#{@analysis.token}.input #{@analysis.threshold} ./data-analysis-fimi03/outputs/#{@analysis.token}.output") {@system_return}
      allow(@job).to receive(:delete_input_file) {@delete_input_file_return}
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
        @create_input_file_return = "./data-analysis-fimi03/inputs/#{@analysis.token}.input"
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
        @create_input_file_return = "./data-analysis-fimi03/inputs/#{@analysis.token}.input"
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

  describe '#get_occurrences_matching_analysis' do
    #                  start_date                                       end_date
    #-----------------------|----------------------------------------------|---------
    #    occ1_s1 occ2_s1    |      occ_1_symptom_1      occ_2_symptom_1    | <= each user have those occurrences
    #        occ1_s2        |                 occ_1_symptom_2              |
    #-----------------------|----------------------------------------------|---------
    context 'when there are 5 users in the database having 3 occurrences (2 of the same symptom and 1 other) between the start_date and end_date of the report and 3 occurrences outside this range' do
      before(:each) do
        @users = create_list(:user, 5)
        @symptoms = create_list(:symptom, 2)
        @users.each do |user|
          create_list(:occurrence, 2, user_id: user.id, symptom_id: @symptoms[0].id, date: @analysis.start_date + 1.hour)
          create_list(:occurrence, 1, user_id: user.id, symptom_id: @symptoms[1].id, date: @analysis.start_date + 1.hour)
          create_list(:occurrence, 2, user_id: user.id, symptom_id: @symptoms[0].id, date: @analysis.start_date - 1.day)
          create_list(:occurrence, 1, user_id: user.id, symptom_id: @symptoms[1].id, date: @analysis.start_date - 1.day)
        end
      end

      subject {@job.get_occurrences_matching_analysis @analysis}

      it 'returns a list of 10 occurrences' do
        expect(subject.length).to eq 10
      end

      it 'returns a list with the 5 ids of users' do
        users_ids = []
        subject.each do |occurrrence|
          users_ids << occurrrence.user_id
        end

        @users.each do |user|
          expect(users_ids).to include user.id
        end
      end

      it 'returns a list with the ids of the 2 symptoms' do
        symptoms_ids = []
        subject.each do |occurrence|
          symptoms_ids << occurrence.symptom_id
        end

        @symptoms.each do |symptom|
          expect(symptoms_ids).to include symptom.id
        end
      end

      it 'returns a list ordered by user_id' do
        expected_users_id = []
        @users.each do |user|
          expected_users_id << user.id
        end
        expected_users_id.sort

        expected_users_id.each_with_index do |user_id, index|
          expect(subject[index * 2].user_id).to eq user_id
          expect(subject[index * 2 + 1].user_id).to eq user_id
        end
      end
    end
  end

  describe '#create_input_file' do
    #                  start_date                                       end_date
    #-----------------------|----------------------------------------------|---------
    #    occ1_s1 occ2_s1    |      occ_1_symptom_1      occ_2_symptom_1    | <= each user have those occurrences
    #        occ1_s2        |                 occ_1_symptom_2              |
    #-----------------------|----------------------------------------------|---------
    context 'when there are 5 users in the database having 3 occurrences (2 of the same symptom and 1 other) between the start_date and end_date of the report and 3 occurrences outside this range' do
      before(:each) do
        @users = create_list(:user, 5)
        @symptoms = create_list(:symptom, 2)
        @users.each do |user|
          create_list(:occurrence, 2, user_id: user.id, symptom_id: @symptoms[0].id, date: @analysis.start_date + 1.hour)
          create_list(:occurrence, 1, user_id: user.id, symptom_id: @symptoms[1].id, date: @analysis.start_date + 1.hour)
          create_list(:occurrence, 2, user_id: user.id, symptom_id: @symptoms[0].id, date: @analysis.start_date - 1.day)
          create_list(:occurrence, 1, user_id: user.id, symptom_id: @symptoms[1].id, date: @analysis.start_date - 1.day)
        end

        allow(@job).to receive(:system)
      end

      before(:each) do
        allow(@job).to receive(:system)
      end

      it 'creates a file containing by calling "system touch token.input"' do
        expect(@job).to receive(:system).with("touch ./data-analysis-fimi03/inputs/#{@analysis.token}.input")
        @job.create_input_file @analysis
      end

      it 'writes 5 times to the input file a line containing the 2 symptoms ids' do
        expect(@job).to receive(:system).with("touch ./data-analysis-fimi03/inputs/#{@analysis.token}.input").ordered
        expect(@job).to receive(:system).exactly(5).times.with(/echo '((#{@symptoms[0].id}|#{@symptoms[1].id}) ?)+' >> \.\/data-analysis-fimi03\/inputs\/#{@analysis.token}\.input/).ordered
        @job.create_input_file @analysis
      end

      it 'returns the input_path' do
        result = @job.create_input_file @analysis
        expect(result).to eq "./data-analysis-fimi03/inputs/#{@analysis.token}.input"
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
end
