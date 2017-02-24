require 'rails_helper'

RSpec.shared_examples 'all CountPerDate have count=0' do
  it 'has count=0 for all instances of CountPerDate' do
    subject.each do |count_per_date|
      expect(count_per_date.count).to eq 0
    end
  end
end

RSpec.shared_examples 'the result looks like [6, 6, 1]' do
  it 'returns an array of length 3' do
    expect(subject.length).to eq 3
  end

  it 'contains a count of 6 for the start_date element' do
    expect(subject[0].count).to eq 6
  end

  it 'contains a count of 6 for the second element' do
    expect(subject[1].count).to eq 6
  end

  it 'contains a count of 1 for the third element' do
    expect(subject[2].count).to eq 1
  end
end

RSpec.describe CountPerDateFactory do
  start_date = Time.zone.parse('2005-10-10 10:10:10')

  describe '.compute_number_of_units_between' do
    subject { CountPerDateFactory.compute_number_of_units_between(start_date, end_date, unit) }
    let(:start_date) { start_date }

    context 'when unit = hours' do
      let(:unit) { 'hours' }

      context 'when start date is 2 hours before end date' do
        let(:end_date) { start_date + 2.hours }

        it { is_expected.to eq 2 }
      end

      context 'when start date is 2 hours after end date' do
        let(:end_date) { start_date - 2.hours }

        it { is_expected.to eq 2 }
      end

      context 'when start date is equal to end date' do
        let(:end_date) { start_date }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 minutes before end date' do
        let(:end_date) { start_date + 2.minutes }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 minutes after end date' do
        let(:end_date) { start_date - 2.minutes }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 days before end date' do
        let(:end_date) { start_date + 2.days }

        it { is_expected.to eq 48 }
      end

      context 'when start date is 2 days after end date' do
        let(:end_date) { start_date - 2.days }

        it { is_expected.to eq 48 }
      end
    end

    context 'when unit = days' do
      let(:unit) { 'days' }

      context 'when start date is 2 hours before end date' do
        let(:end_date) { start_date + 2.hours }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 hours after end date' do
        let(:end_date) { start_date - 2.hours }

        it { is_expected.to eq 0 }
      end

      context 'when start date is equal to end date' do
        let(:end_date) { start_date }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 minutes before end date' do
        let(:end_date) { start_date + 2.minutes }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 minutes after end date' do
        let(:end_date) { start_date - 2.minutes }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 days before end date' do
        let(:end_date) { start_date + 2.days }

        it { is_expected.to eq 2 }
      end

      context 'when start date is 2 days after end date' do
        let(:end_date) { start_date - 2.days }

        it { is_expected.to eq 2 }
      end
    end

    context 'when unit = months' do
      let(:unit) { 'months' }

      context 'when start date is 2 hours before end date' do
        let(:end_date) { start_date + 2.hours }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 hours after end date' do
        let(:end_date) { start_date - 2.hours }

        it { is_expected.to eq 0 }
      end

      context 'when start date is equal to end date' do
        let(:end_date) { start_date }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 months before end date' do
        let(:end_date) { start_date + 2.months }

        it { is_expected.to eq 2 }
      end

      context 'when start date is 2 months after end date' do
        let(:end_date) { start_date - 2.months }

        it { is_expected.to eq 2 }
      end

      context 'when start date is 2 years before end date' do
        let(:end_date) { start_date + 2.years }

        it { is_expected.to eq 24 }
      end

      context 'when start date is 2 years after end date' do
        let(:end_date) { start_date - 2.years }

        it { is_expected.to eq 24 }
      end
    end

    context 'when unit = years' do
      let(:unit) { 'years' }

      context 'when start date is 2 hours before end date' do
        let(:end_date) { start_date + 2.hours }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 hours after end date' do
        let(:end_date) { start_date - 2.hours }

        it { is_expected.to eq 0 }
      end

      context 'when start date is equal to end date' do
        let(:end_date) { start_date }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 years before end date' do
        let(:end_date) { start_date + 2.years }

        it { is_expected.to eq 2 }
      end

      context 'when start date is 2 years after end date' do
        let(:end_date) { start_date - 2.years }

        it { is_expected.to eq 2 }
      end

      context 'when start date is 2 months before end date' do
        let(:end_date) { start_date + 2.months }

        it { is_expected.to eq 0 }
      end

      context 'when start date is 2 months after end date' do
        let(:end_date) { start_date - 2.months }

        it { is_expected.to eq 0 }
      end
    end

    context 'when unit is invalid' do
      let(:unit) { 'invalid' }
      let(:end_date) { start_date - 2.months }

      it { expect { subject }.to raise_error ArgumentError }
    end
  end

  describe '.generate_array_for_unit' do
    subject { CountPerDateFactory.generate_array_for_unit(start_date, end_date, unit) }

    context 'when start_date and end_date are separated by 1 year, 2 months, 3 days and 4 hours' do
      let(:start_date) { start_date }
      let(:end_date) { start_date + 1.year + 2.months + 3.days + 4.hours }

      context 'with unit = hours' do
        let(:unit) { 'hours' }

        it 'returns 10301 elements separated by 1 hour' do
          expect(subject.length).to eq 10301
          (0..10301-1).each { |i| expect(subject[i].date).to eq start_date + i.hours }
        end
      end

      context 'with unit = days' do
        let(:unit) { 'days' }

        it 'returns 430 elements separated by 1 day' do
          expect(subject.length).to eq 430
          (0..430-1).each { |i|
            expect(subject[i].date).to eq start_date + i.days
          }
        end
      end

      context 'with unit = month' do
        let(:unit) { 'months' }

        it 'returns 15 elements separated by 1 month' do
          expect(subject.length).to eq 15
          (0..15-1).each { |i|
            expect(subject[i].date).to eq start_date + i.months
          }
        end
      end

      context 'with unit = years' do
        let(:unit) { 'years' }

        it 'returns 2 elements separated by 1 year' do
          expect(subject.length).to eq 2
          for i in 0..2-1 do
            expect(subject[i].date).to eq start_date + i.years
          end
        end
      end

      context 'with invalid unit' do
        let(:unit) { 'invalid' }

        it 'raise a NoMethodError' do
          expect { subject }.to raise_error ArgumentError
        end
      end
    end
  end

  describe '.group_by' do
    subject { CountPerDateFactory.group_by(occurrences, start_date, end_date, unit) }

    context 'when an array of 10 occurrences is given, each separated by one hour' do
      number_of_occurrences = 10
      let(:occurrences) {
        occurrences = Array.new(number_of_occurrences) { Occurrence.new }
        for i in 0..number_of_occurrences-1 do
          occurrences[i].date = (start_date + i.hour)
        end
        occurrences
      }

      context 'when start_date is at the same date as the first occurrence' do
        let(:start_date) { start_date }

        context 'when end_date is at the same date as the last occurrence' do
          let(:end_date) { start_date+(number_of_occurrences-1).hours }

          context 'with unit = hours' do
            let(:unit) { 'hours' }

            it 'returns an array of length 10' do
              expect(subject.length).to eq 10
            end

            it 'contains a "count" of 1 for each CountPerDate' do
              subject.each do |count_per_date|
                expect(count_per_date.count).to eq 1
              end
            end
          end

          context 'with unit = days' do
            let(:unit) { 'days' }

            it 'returns an array of length 1' do
              expect(subject.length).to eq 1
            end

            it 'contains a "count" of 10' do
              expect(subject[0].count).to eq 10
            end
          end

          context 'with unit = months' do
            let(:unit) { 'months' }

            it 'returns an array of length 1' do
              expect(subject.length).to eq 1
            end

            it 'contains a "count" of 10' do
              expect(subject[0].count).to eq 10
            end
          end

          context 'with unit = years' do
            let(:unit) { 'years' }

            it 'returns an array of length 1' do
              expect(subject.length).to eq 1
            end

            it 'contains a "count" of 10' do
              expect(subject[0].count).to eq 10
            end
          end
        end
      end
    end


    context 'when an empty array is given' do
      let(:occurrences) { Array.new }
      let(:start_date) { start_date }
      let(:end_date) { start_date + 1.day }
      let(:unit) { 'hours' }

      it 'has a length equal to the number of units between the start_date and the end_date +1' do
        expect(subject.length).to eq 25
      end
    end

    context 'when nil is given' do
      let(:occurrences) { nil }
      let(:start_date) { start_date }
      let(:end_date) { start_date + 1.day }
      let(:unit) { 'hours' }

      it 'raises an error' do
        expect { subject }.to raise_error NoMethodError
      end
    end
  end
end
