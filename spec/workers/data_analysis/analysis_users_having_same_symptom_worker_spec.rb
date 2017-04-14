require 'rails_helper'
RSpec.describe DataAnalysis::AnalysisUsersHavingSameSymptomWorker, type: :worker do
  before(:each) do
    @job = DataAnalysis::AnalysisUsersHavingSameSymptomWorker.new
    @analysis = create(:analysis_users_having_same_symptom)
    @input_path = "./data-analysis-fimi03/inputs/#{@analysis.token}.input"
    @output_path = "./data-analysis-fimi03/outputs/#{@analysis.token}.output"
  end

  describe '#generate_input_file' do
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

      it 'writes 5 times to the input file a line containing the 2 symptoms ids' do
        expect(@job).to receive(:system).exactly(5).times.with(/echo '((#{@symptoms[0].id}|#{@symptoms[1].id}) ?)+' >> \.\/data-analysis-fimi03\/inputs\/#{@analysis.token}\.input/).ordered
        @job.generate_input_file @analysis, @input_path
      end
    end
  end

  describe '#retrieve_analysis_from_id' do
    it 'returns an instance of DataAnalysis::AnalysisUsersHavingSameSymptom' do
      result = @job.retrieve_analysis_from_id @analysis.id
      expect(result).to be_instance_of DataAnalysis::AnalysisUsersHavingSameSymptom
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
        expected_users_id.sort!

        expected_users_id.each_with_index do |user_id, index|
          expect(subject[index * 2].user_id).to eq user_id
          expect(subject[index * 2 + 1].user_id).to eq user_id
        end
      end
    end
  end
end
