require 'rails_helper'
require 'support/shared_example_symptoms_counts_factory'

RSpec.describe SymptomsCountsFactory do
  describe '.build_for' do
    subject { SymptomsCountsFactory.build_for user_id, start_date, end_date, unit, symptoms }

    number_of_symptoms = 2

    context 'with a valid user id' do
      let(:user_id) { @user.id }

      context 'with 2 symptoms, each with 6 occurrences, spread across 3 hours' do
        before(:each) do
          @user, @symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours(number_of_symptoms)
        end

        context 'with a given interval of 24 hours, including all the occurrences of each symptom' do
          let(:start_date) { Time.zone.parse('2005-01-01 00:00:00') }
          let(:end_date) { Time.zone.parse('2005-01-01 23:59:59') }

          context 'with an undefined unit parameter' do
            unit = 'days'
            let(:unit) { nil }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 1, Array.new(24) { 6 }
          end

          context 'with unit = "days"' do
            unit = 'days'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 1, Array.new(24) { 6 }
          end

          context 'with unit = "hours"' do
            unit = 'hours'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 24, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          end

          context 'with unit = "months"' do
            unit = 'months'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 1, Array.new(24) { 6 }
          end

          context 'with unit = "years"' do
            unit = 'years'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 1, Array.new(24) { 6 }
          end

        end

        context 'with a given interval of 12 hours, excluding the last occurrences' do
          let(:start_date) { Time.zone.parse('2005-01-01 00:00:00') }
          let(:end_date) { Time.zone.parse('2005-01-01 11:59:59') }

          context 'with unit = "days"' do
            unit = 'days'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 1, Array.new(24) { 5 }
          end

          context 'with unit = "hours"' do
            unit = 'hours'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 12, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2]
          end

        end

        context 'with a given interval of 12 hours, excluding the first occurrences' do
          let(:start_date) { Time.zone.parse('2005-01-01 12:00:00') }
          let(:end_date) { Time.zone.parse('2005-01-01 23:59:59') }

          context 'with unit = "days"' do
            unit = 'days'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 1, Array.new(24) { 1 }
          end

          context 'with unit = "hours"' do
            unit = 'hours'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, number_of_symptoms, 12, [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
          end

        end

        context 'with a given interval of 2 hours, excluding all occurrences' do
          let(:start_date) { Time.zone.parse('2005-01-01 00:00:00') }
          let(:end_date) { Time.zone.parse('2005-01-01 1:59:59') }

          context 'with unit = "days"' do
            unit = 'days'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, 0, 0, nil
          end

          context 'with unit = "hours"' do
            unit = 'hours'
            let(:unit) { unit }

            include_examples 'different values for symptoms parameter', unit, 0, 0, nil
          end

        end
      end
    end

    context 'with an invalid user id' do
      let(:user_id) { -1 }

      unit = 'hours'
      let(:start_date) { Time.at(0) }
      let(:end_date) { Time.now }
      let(:unit) { unit }

      before(:each) do
        @user, @symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours(number_of_symptoms)
      end

      include_examples 'different values for symptoms parameter', unit, 0, 0, nil
    end


  end
end
