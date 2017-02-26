require 'rails_helper'
require 'support/shared_example_symptom_count_factory'

RSpec.describe SymptomsCountsFactory do

  describe '.build_for' do
    subject { SymptomsCountsFactory.build_for user_id, start_date, end_date, unit, symptoms }

    number_of_symptoms = 2
    before(:each) do
      @user, @symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours(number_of_symptoms)
    end

    context 'with a valid user' do
      let(:user_id) {@user.id}

      context 'with only the required parameter user'  do

        it 'has a unit = "hours"' do
          expect(subject.unit).to eq 'hours'
        end

        it 'has 2 symptoms' do
          expect(subject.symptoms.length).to eq number_of_symptoms
        end

        describe 'each symptom_count' do
          it 'has 3 counts' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts.length).to eq 3
            end
          end

          it 'has a first count with date = @january_2005_10_o_clock' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts[0].date).to eq @january_2005_10_o_clock
            end
          end

          it 'has a first count with count = 3' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts[0].count).to eq 3
            end
          end

          it 'has a second count with date = @one_hour_later' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts[1].date).to eq @one_hour_later
            end
          end

          it 'has a second count with count = 2' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts[1].count).to eq 2
            end
          end

          it 'has a third count with date = @two_hours_later' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts[2].date).to eq @two_hours_later
            end
          end

          it 'has a third count with count = 1' do
            subject.symptoms.each do |symptom_count|
              expect(symptom_count.counts[2].count).to eq 1
            end
          end
        end
      end
    end

  end
end
