require 'rails_helper'
require 'support/shared_example_symptoms_counts_factory'

RSpec.describe SymptomCountFactory do
  describe '.get_symptom' do
    before(:each) do
      @user, symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours
      @symptom = symptoms[0]
    end

    subject { SymptomCountFactory.get_symptom symptom_id, user_id, start_date, end_date }

    context 'with existing symptom_id, user_id' do
      let(:symptom_id) { @symptom.id }
      let(:user_id) { @user.id }

      context 'whith all occurrences within the given interval' do
        let(:start_date) { @january_2005_10_o_clock - 1.day }
        let(:end_date) { @january_2005_10_o_clock + 1.day }

        it 'returns the symptom with its id' do
          expect(subject.id).to eq @symptom.id
        end

        it 'contains 6 occurrences' do
          expect(subject.occurrences.length).to eq 6
        end

        it 'contains occurrences with the correct user_id' do
          subject.occurrences.each do |occurrence|
            expect(occurrence.user_id).to eq @user.id
          end
        end
      end

      context 'with no occurrences within the given interval' do
        let(:start_date) { @january_2005_10_o_clock - 2.day }
        let(:end_date) { @january_2005_10_o_clock - 1.day }

        it 'raises an exception' do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'with 3 occurrences excluded because they are after end_date' do
        let(:start_date) { @january_2005_10_o_clock - 1.day }
        let(:end_date) { @january_2005_10_o_clock + 10.minutes }

        it 'contains 3 occurrences' do
          expect(subject.occurrences.length).to eq 3
        end
      end

      context 'with 3 occurrences excluded because they are before start_date' do
        let(:start_date) { @january_2005_10_o_clock + 10.minutes }
        let(:end_date) { @january_2005_10_o_clock + 1.day }

        it 'contains 3 occurrences' do
          expect(subject.occurrences.length).to eq 3
        end
      end
    end

    context 'with invalid user_id' do
      let(:user_id) { -1 }
      let(:symptom_id) { @symptom.id }

      let(:start_date) { @january_2005_10_o_clock - 1.day }
      let(:end_date) { @january_2005_10_o_clock + 1.day }

      it 'raises an exception' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'with invalid symptom_id' do
      let(:user_id) { @user.id }
      let(:symptom_id) { -1 }

      let(:start_date) { @january_2005_10_o_clock - 1.day }
      let(:end_date) { @january_2005_10_o_clock + 1.day }

      it 'raises an exception' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe '.build_for' do
    subject { SymptomCountFactory.build_for symptom_id, user_id, start_date, end_date, unit }

    context 'with existing symptom_id, user_id' do
      let(:symptom_id) { @symptom.id }
      let(:user_id) { @user.id }

      context 'when unit = hours' do
        let(:unit) { 'hours' }

        before(:each) do
          @user, symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours
          @symptom = symptoms[0]
        end

        context 'when the start_date is exactly equal to the first occurrence and the end_date is exactly equals to the last occurrence' do
          let(:start_date) { @january_2005_10_o_clock }
          let(:end_date) { @two_hours_later }

          it 'has the correct symptom_id' do
            expect(subject.id).to eq @symptom.id
          end

          it 'has the correct symptom name' do
            expect(subject.name).to eq @symptom.name
          end

          it 'has 3 counts' do
            expect(subject.counts.length).to eq 3
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 10:00:00' do
              expect(@first_count.date).to eq @january_2005_10_o_clock
            end

            it ' has 3 occurrences' do
              expect(@first_count.count).to eq 3
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 11:00:00' do
              expect(@second_count.date).to eq @one_hour_later
            end

            it ' has 2 occurrences' do
              expect(@second_count.count).to eq 2
            end
          end

          describe 'the third count' do
            before(:each) do
              @third_count = subject.counts[2]
            end

            it 'is for 12:00:00' do
              expect(@third_count.date).to eq @two_hours_later
            end

            it 'has 1 occurrence' do
              expect(@third_count.count).to eq 1
            end
          end
        end

        context 'when the start_date exclude the first 3 occurrences' do
          let(:start_date) { @january_2005_10_o_clock + 30.minutes }
          let(:end_date) { @two_hours_later }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 10:30:00' do
              expect(@first_count.date).to eq @january_2005_10_o_clock + 30.minutes
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 11:30:00' do
              expect(@second_count.date).to eq @one_hour_later + 30.minutes
            end

            it 'has 1 occurrence' do
              expect(@second_count.count).to eq 1
            end
          end
        end

        context 'when the start_date excludes the first 3 occurrences and the end_date excludes the last occurrence' do
          let(:start_date) { @january_2005_10_o_clock + 30.minutes }
          let(:end_date) { @two_hours_later - 30.minutes }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 10:30:00' do
              expect(@first_count.date).to eq @january_2005_10_o_clock + 30.minutes
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 11:30:00' do
              expect(@second_count.date).to eq @one_hour_later + 30.minutes
            end

            it 'has 0 occurrence' do
              expect(@second_count.count).to eq 0
            end
          end
        end
      end

      context 'when unit = days' do
        before(:each) do
          @user, symptoms, @january_2005_10_o_clock, @one_day_later, @two_days_later = create_symptom_and_occurrences_for_spec_per_days
          @symptom = symptoms[0]
        end
        let(:unit) { 'days' }

        context 'when the start_date is exactly equal to the first occurrence and the end_date is exactly equals to the last occurrence' do
          let(:start_date) { @january_2005_10_o_clock }
          let(:end_date) { @two_days_later }

          it 'has the correct symptom_id' do
            expect(subject.id).to eq @symptom.id
          end

          it 'has the correct symptom name' do
            expect(subject.name).to eq @symptom.name
          end

          it 'has 3 counts' do
            expect(subject.counts.length).to eq 3
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-01-01' do
              expect(@first_count.date).to eq @january_2005_10_o_clock
            end

            it ' has 3 occurrences' do
              expect(@first_count.count).to eq 3
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2005-01-02' do
              expect(@second_count.date).to eq @one_day_later
            end

            it ' has 2 occurrences' do
              expect(@second_count.count).to eq 2
            end
          end

          describe 'the third count' do
            before(:each) do
              @third_count = subject.counts[2]
            end

            it 'is for 2005-01-03' do
              expect(@third_count.date).to eq @two_days_later
            end

            it 'has 1 occurrence' do
              expect(@third_count.count).to eq 1
            end
          end
        end

        context 'when the start_date exclude the first 3 occurrences' do
          let(:start_date) { @one_day_later }
          let(:end_date) { @two_days_later }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-01-02' do
              expect(@first_count.date).to eq @one_day_later
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2005-01-03' do
              expect(@second_count.date).to eq @two_days_later
            end

            it 'has 1 occurrence' do
              expect(@second_count.count).to eq 1
            end
          end
        end

        context 'when the start_date excludes the first 3 occurrences and the end_date excludes the last occurrence' do
          let(:start_date) { @one_day_later }
          let(:end_date) { @two_days_later - 30.minutes }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-01-02' do
              expect(@first_count.date).to eq @one_day_later
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2005-01-03' do
              expect(@second_count.date).to eq @two_days_later
            end

            it 'has 0 occurrence' do
              expect(@second_count.count).to eq 0
            end
          end
        end
      end

      context 'when unit = months' do
        before(:each) do
          @user, symptoms, @january_2005_10_o_clock, @one_month_later, @two_months_later = create_symptom_and_occurrences_for_spec_per_months
          @symptom = symptoms[0]
        end
        let(:unit) { 'months' }

        context 'when the start_date is exactly equal to the first occurrence and the end_date is exactly equals to the last occurrence' do
          let(:start_date) { @january_2005_10_o_clock }
          let(:end_date) { @two_months_later }

          it 'has the correct symptom_id' do
            expect(subject.id).to eq @symptom.id
          end

          it 'has the correct symptom name' do
            expect(subject.name).to eq @symptom.name
          end

          it 'has 3 counts' do
            expect(subject.counts.length).to eq 3
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-01-01' do
              expect(@first_count.date).to eq @january_2005_10_o_clock
            end

            it ' has 3 occurrences' do
              expect(@first_count.count).to eq 3
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2005-02-01' do
              expect(@second_count.date).to eq @one_month_later
            end

            it ' has 2 occurrences' do
              expect(@second_count.count).to eq 2
            end
          end

          describe 'the third count' do
            before(:each) do
              @third_count = subject.counts[2]
            end

            it 'is for 2005-03-01' do
              expect(@third_count.date).to eq @two_months_later
            end

            it 'has 1 occurrence' do
              expect(@third_count.count).to eq 1
            end
          end
        end

        context 'when the start_date exclude the first 3 occurrences' do
          let(:start_date) { @one_month_later }
          let(:end_date) { @two_months_later }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-02-01' do
              expect(@first_count.date).to eq @one_month_later
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2005-03-01' do
              expect(@second_count.date).to eq @two_months_later
            end

            it 'has 1 occurrence' do
              expect(@second_count.count).to eq 1
            end
          end
        end

        context 'when the start_date excludes the first 3 occurrences and the end_date excludes the last occurrence' do
          let(:start_date) { @one_month_later }
          let(:end_date) { @two_months_later - 30.minutes }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-02-01' do
              expect(@first_count.date).to eq @one_month_later
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2005-03-01' do
              expect(@second_count.date).to eq @two_months_later
            end

            it 'has 0 occurrence' do
              expect(@second_count.count).to eq 0
            end
          end
        end
      end

      context 'when unit = years' do
        before(:each) do
          @user, symptoms, @january_2005_10_o_clock, @one_year_later, @two_years_later = create_symptom_and_occurrences_for_spec_per_years
          @symptom = symptoms[0]
        end
        let(:unit) { 'years' }

        context 'when the start_date is exactly equal to the first occurrence and the end_date is exactly equals to the last occurrence' do
          let(:start_date) { @january_2005_10_o_clock }
          let(:end_date) { @two_years_later }

          it 'has the correct symptom_id' do
            expect(subject.id).to eq @symptom.id
          end

          it 'has the correct symptom name' do
            expect(subject.name).to eq @symptom.name
          end

          it 'has 3 counts' do
            expect(subject.counts.length).to eq 3
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2005-01-01' do
              expect(@first_count.date).to eq @january_2005_10_o_clock
            end

            it ' has 3 occurrences' do
              expect(@first_count.count).to eq 3
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2006-01-01' do
              expect(@second_count.date).to eq @one_year_later
            end

            it ' has 2 occurrences' do
              expect(@second_count.count).to eq 2
            end
          end

          describe 'the third count' do
            before(:each) do
              @third_count = subject.counts[2]
            end

            it 'is for 2007-01-01' do
              expect(@third_count.date).to eq @two_years_later
            end

            it 'has 1 occurrence' do
              expect(@third_count.count).to eq 1
            end
          end
        end

        context 'when the start_date exclude the first 3 occurrences' do
          let(:start_date) { @one_year_later }
          let(:end_date) { @two_years_later }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2006-01-01' do
              expect(@first_count.date).to eq @one_year_later
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2007-01-01' do
              expect(@second_count.date).to eq @two_years_later
            end

            it 'has 1 occurrence' do
              expect(@second_count.count).to eq 1
            end
          end
        end

        context 'when the start_date excludes the first 3 occurrences and the end_date excludes the last occurrence' do
          let(:start_date) { @one_year_later }
          let(:end_date) { @two_years_later - 30.minutes }

          it 'has 2 counts' do
            expect(subject.counts.length).to eq 2
          end

          describe 'the first count' do
            before(:each) do
              @first_count = subject.counts[0]
            end

            it 'is for 2006-01-01' do
              expect(@first_count.date).to eq @one_year_later
            end

            it 'has 2 occurrences' do
              expect(@first_count.count).to eq 2
            end
          end

          describe 'the second count' do
            before(:each) do
              @second_count = subject.counts[1]
            end

            it 'is for 2007-01-01' do
              expect(@second_count.date).to eq @two_years_later
            end

            it 'has 0 occurrence' do
              expect(@second_count.count).to eq 0
            end
          end
        end
      end

    end

    context 'with invalid user_id' do
      let(:user_id) { -1 }
      let(:symptom_id) { @symptom.id }

      let(:start_date) { @january_2005_10_o_clock - 1.day }
      let(:end_date) { @january_2005_10_o_clock + 1.day }
      let(:unit) { 'hours' }

      before(:each) do
        @user, symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours
        @symptom = symptoms[0]
      end

      it 'raises an exception' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'with invalid symptom_id' do
      let(:user_id) { @user.id }
      let(:symptom_id) { -1 }

      let(:start_date) { @january_2005_10_o_clock - 1.day }
      let(:end_date) { @january_2005_10_o_clock + 1.day }
      let(:unit) { 'hours' }

      before(:each) do
        @user, symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec_per_hours
        @symptom = symptoms[0]
      end

      it 'raises an exception' do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end
end
