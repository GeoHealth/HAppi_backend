require 'rails_helper'
require 'support/shared_example_symptom_count_factory'

RSpec.describe SymptomCountFactory do
  before(:each) do
    @user, symptoms, @january_2005_10_o_clock, @one_hour_later, @two_hours_later = create_symptom_and_occurrences_for_spec
    @symptom = symptoms[0]
  end

  describe '.get_symptom' do
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
  end

  describe '.per_hour' do

    context 'with existing symptom_id, user_id' do
      let(:symptom_id) { @symptom.id }
      let(:user_id) { @user.id }

      context 'when no start date and end date are given' do
        subject { SymptomCountFactory.per_hours symptom_id, user_id }

        include_examples 'all occurrences are included in the given interval'
      end

      context 'when all occurrences are in the interval given by start_date and end_date' do
        let(:start_date) { @january_2005_10_o_clock - 1.day }
        let(:end_date) { @january_2005_10_o_clock + 10.day }

        subject { SymptomCountFactory.per_hours symptom_id, user_id, start_date, end_date }

        include_examples 'all occurrences are included in the given interval'
      end

      context 'when the start_date is exactly equal to the first occurrence' do
        let(:start_date) { @january_2005_10_o_clock }
        let(:end_date) { @january_2005_10_o_clock + 10.day }

        subject { SymptomCountFactory.per_hours symptom_id, user_id, start_date, end_date }

        include_examples 'all occurrences are included in the given interval'
      end

      context 'when the start_date is exactly equal to the first occurrence and the end_date is exactly equals to the last occurrence' do
        let(:start_date) { @january_2005_10_o_clock }
        let(:end_date) { @two_hours_later }

        subject { SymptomCountFactory.per_hours symptom_id, user_id, start_date, end_date }

        include_examples 'all occurrences are included in the given interval'
      end
      
      context 'when the start_date exclude the first 3 occurrences' do
        let(:start_date) { @january_2005_10_o_clock + 30.minutes }
        let(:end_date) { @two_hours_later }

        subject { SymptomCountFactory.per_hours symptom_id, user_id, start_date, end_date }

        it 'has 2 counts' do
          expect(subject.counts.length).to eq 2
        end

        describe 'the first count' do
          before(:each) do
            @first_count = subject.counts[0]
          end

          it 'is for 11:00:00' do
            expect(@first_count.date).to eq @one_hour_later
          end

          it ' has 2 occurrences' do
            expect(@first_count.count).to eq 2
          end
        end

        describe 'the second count' do
          before(:each) do
            @second_count = subject.counts[1]
          end

          it 'is for 12:00:00' do
            expect(@second_count.date).to eq @two_hours_later
          end

          it ' has 1 occurrence' do
            expect(@second_count.count).to eq 1
          end
        end
      end

      context 'when the start_date excludes the first 3 occurrences and the end_date excludes the last occurrence' do
        let(:start_date) { @january_2005_10_o_clock + 30.minutes }
        let(:end_date) { @two_hours_later - 30.minutes}

        subject { SymptomCountFactory.per_hours symptom_id, user_id, start_date, end_date }

        it 'has 1 counts' do
          expect(subject.counts.length).to eq 1
        end

        describe 'the first count' do
          before(:each) do
            @first_count = subject.counts[0]
          end

          it 'is for 11:00:00' do
            expect(@first_count.date).to eq @one_hour_later
          end

          it ' has 2 occurrences' do
            expect(@first_count.count).to eq 2
          end
        end
      end
    end
  end
end
