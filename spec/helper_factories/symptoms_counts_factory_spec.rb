require 'rails_helper'
require 'support/shared_example_symptom_count_factory'

RSpec.describe SymptomsCountsFactory do

  describe '.build_for' do
    context 'when the unit is not given' do
      it 'calls per_days_for_user' do
        expect(SymptomsCountsFactory).to receive(:per_days_for_user)
        SymptomsCountsFactory.build_for nil
      end
    end

    context 'when the unit is days' do
      it 'calls per_days_for_user' do
        expect(SymptomsCountsFactory).to receive(:per_days_for_user)
        SymptomsCountsFactory.build_for nil, nil, nil, 'days'
      end
    end

    context 'when the unit is hours' do
      it 'calls per_hours_for_user' do
        expect(SymptomsCountsFactory).to receive(:per_hours_for_user)
        SymptomsCountsFactory.build_for nil, nil, nil, 'hours'
      end
    end

    context 'when the unit is months' do
      it 'calls per_months_for_user' do
        expect(SymptomsCountsFactory).to receive(:per_months_for_user)
        SymptomsCountsFactory.build_for nil, nil, nil, 'months'
      end
    end

    context 'when the unit is years' do
      it 'calls per_years_for_user' do
        expect(SymptomsCountsFactory).to receive(:per_years_for_user)
        SymptomsCountsFactory.build_for nil, nil, nil, 'years'
      end
    end
  end

  describe '.per_hour_for_user' do
    number_of_symptoms = 2
    before(:each) do
      @user, @symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec(number_of_symptoms)
    end

    context 'with a valid user' do
      let(:user) {@user}

      context 'with only the required parameter user'  do
        subject { SymptomsCountsFactory.per_hours_for_user user }

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
