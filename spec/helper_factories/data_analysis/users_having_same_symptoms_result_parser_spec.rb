require 'rails_helper'

RSpec.describe DataAnalysis::UsersHavingSameSymptomsResultParser do
  describe '.parse_result' do
    context 'when the output file contains 2 lines with 3 symptoms each' do
      before(:each) do
        @symptoms = create_list(:symptom, 3)
        @analysis = create(:analysis_users_having_same_symptom)
        @output_file =  "./data-analysis-fimi03/outputs/#{@analysis.token}.output"
        system "touch #{@output_file}"
        system "echo '#{@symptoms[0].id} #{@symptoms[1].id} #{@symptoms[2].id} (1006)' >> #{@output_file}"
        system "echo '#{@symptoms[0].id} #{@symptoms[1].id} #{@symptoms[2].id} (1993)' >> #{@output_file}"

        @results = DataAnalysis::UsersHavingSameSymptomsResultParser.parse_result @analysis
      end

      after(:each) do
        system "rm #{@output_file}"
      end

      it 'returns an array having 2 elements' do
        expect(@results.length).to eq 2
      end

      describe 'the first element' do
        subject {@results.first}

        it 'has a number_of_match equals to 1006' do
          expect(subject[:number_of_match]).to eq '1006'
        end

        it 'has 3 symptoms' do
          expect(subject[:symptoms].length).to eq 3
        end

        it 'has the 3 created symptoms' do
          expected_ids = [@symptoms[0].id, @symptoms[1].id, @symptoms[2].id]
          subject[:symptoms].each do |symptom|
            expect(expected_ids).to include symptom.id
          end
        end
      end

      describe 'the second element' do
        subject {@results.last}

        it 'has a number_of_match equals to 1993' do
          expect(subject[:number_of_match]).to eq '1993'
        end

        it 'has 3 symptoms' do
          expect(subject[:symptoms].length).to eq 3
        end

        it 'has the 3 created symptoms' do
          expected_ids = [@symptoms[0].id, @symptoms[1].id, @symptoms[2].id]
          subject[:symptoms].each do |symptom|
            expect(expected_ids).to include symptom.id
          end
        end
      end
    end
  end
end