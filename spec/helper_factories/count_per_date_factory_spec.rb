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

  it 'contains a count of 6 for the first element' do
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
  first = Time.zone.parse('2005-10-10 10:10:10')

  describe '.compute_hours_between' do
    subject { CountPerDateFactory.compute_hours_between(first, last) }

    context 'when start date is 2 hours before end date' do
      let(:first) { first }
      let(:last) { first + 2.hours }

      it { is_expected.to eq 2 }
    end

    context 'when start date is 2 hours after end date' do
      let(:first) { first }
      let(:last) { first - 2.hours }

      it { is_expected.to eq 2 }
    end

    context 'when start date is equal to end date' do
      let(:first) { first }
      let(:last) { first }

      it { is_expected.to eq 0 }
    end

    context 'when start date is 2 minutes before end date' do
      let(:first) { first }
      let(:last) { first + 2.minutes }

      it { is_expected.to eq 0 }
    end

    context 'when start date is 2 minutes after end date' do
      let(:first) { first }
      let(:last) { first - 2.minutes }

      it { is_expected.to eq 0 }
    end

    context 'when start date is 2 days before end date' do
      let(:first) { first }
      let(:last) { first + 2.days }

      it { is_expected.to eq 48 }
    end

    context 'when start date is 2 days after end date' do
      let(:first) { first }
      let(:last) { first - 2.days }

      it { is_expected.to eq 48 }
    end
  end

  describe '.generate_array_of_count_per_date_for' do
    subject { CountPerDateFactory.generate_array_per_hours(first, last) }

    context 'when start date is 2 hours before end date' do
      let(:first) { first }
      let(:last) { first + 2.hours }

      it 'returns an array of length 3' do
        expect(subject.length).to eq 3
      end

      it 'contains 3 dates: "first", "first + 1 hour" and "first + 2 hours"' do
        (0..2).each { |i|
          expect(subject[i].date).to eq first + i.hours
        }
      end

      it_behaves_like 'all CountPerDate have count=0'
    end

    context 'when start date is 2 minutes before end date' do
      let(:first) { first }
      let(:last) { first + 2.minutes }

      it 'returns an array of length 1' do
        expect(subject.length).to eq 1
      end

      it 'contains 1 date = first' do
        expect(subject[0].date).to eq first
      end

      it_behaves_like 'all CountPerDate have count=0'
    end

    context 'when start date is 2 hours after end date' do
      let(:first) { first }
      let(:last) { first - 2.hours }

      it 'returns an array of length 3' do
        expect(subject.length).to eq 3
      end

      it 'contains 2 dates: "first", "first + 1 hour" and "first + 2 hours"' do
        (0..1).each { |i|
          expect(subject[i].date).to eq first + i.hours
        }
      end

      it_behaves_like 'all CountPerDate have count=0'
    end

    context 'when start date is 2 days before end date' do
      let(:first) { first }
      let(:last) { first + 2.days }

      it 'returns an array of length 49' do
        expect(subject.length).to eq 49
      end

      it 'contains 49 dates, starting from "first", incremented by 1 hour' do
        (0..48).each { |i|
          expect(subject[i].date).to eq first + i.hours
        }
      end

      it_behaves_like 'all CountPerDate have count=0'
    end
  end

  describe '.generate_array_for_unit' do
    subject { CountPerDateFactory.generate_array_for_unit(first, number_of_elements, unit) }

    context 'with 10 elements' do
      number_of_elements = 10
      let(:number_of_elements) { number_of_elements }

      context 'with unit = hours' do
        let(:unit) { :hours }

        it 'returns 10 elements separated by 1 hour' do
          (0..number_of_elements-1).each { |i|
            expect(subject[i].date).to eq first + i.hours
          }
        end
      end

      context 'with unit = days' do
        let(:unit) { :days }

        it 'returns 10 elements separated by 1 day' do
          (0..number_of_elements-1).each { |i|
            expect(subject[i].date).to eq first + i.days
          }
        end
      end

      context 'with unit = month' do
        let(:unit) { :months }

        it 'returns 10 elements separated by 1 month' do
          (0..number_of_elements-1).each { |i|
            expect(subject[i].date).to eq first + i.months
          }
        end
      end

      context 'with unit = years' do
        let(:unit) { :years }

        it 'returns 10 elements separated by 1 year' do
          for i in 0..number_of_elements-1 do
            expect(subject[i].date).to eq first + i.years
          end
        end
      end

      context 'with invalid unit' do
        let(:unit) { :invalid_unit }

        it 'raise a NoMethodError' do
          expect { subject }.to raise_error NoMethodError
        end
      end
    end
  end

  describe '.per_hour' do
    subject { CountPerDateFactory.per_hour(occurrences) }

    context 'when an array of 10 occurrences is given, each separated by one hour, ordered ASC' do
      number_of_occurrences = 10
      let(:occurrences) {
        occurrences = Array.new(number_of_occurrences) { Occurrence.new }
        for i in 0..number_of_occurrences-1 do
          occurrences[i].date = (first + i.hour)
        end
        occurrences
      }

      it 'returns an array of length 10' do
        expect(subject.length).to eq 10
      end

      it 'contains a "count" of 1 for each CountPerDate' do
        subject.each do |count_per_date|
          expect(count_per_date.count).to eq 1
        end
      end
    end

    context 'when an array of 13 occurrences is given, each separated by 10 minutes, ordered ASC' do
      number_of_occurrences = 13
      let(:occurrences) {
        occurrences = Array.new(number_of_occurrences) { Occurrence.new }
        for i in 0..number_of_occurrences-1 do
          occurrences[i].date = (first + (i * 10).minutes)
        end
        occurrences
      }

      it_behaves_like 'the result looks like [6, 6, 1]'
    end

    context 'when an array of 13 occurrences is given, each separated by 10 minutes, unordered' do
      number_of_occurrences = 13
      let(:occurrences) {
        occurrences = Array.new(number_of_occurrences) { Occurrence.new }
        for i in 0..number_of_occurrences-1 do
          occurrences[i].date = (first - (i * 10).minutes)
        end
        occurrences[0], occurrences[5] = occurrences[5], occurrences[0]
        occurrences
      }

      it_behaves_like 'the result looks like [6, 6, 1]'
    end

    context 'when an array of 13 occurrences is given, each separated by 10 minutes, unordered, and the Timezone is changed' do
      number_of_occurrences = 13
      let(:occurrences) {
        zones = ['Midway Island', 'Hawaii', 'Alaska', 'Pacific Time (US & Canada)', 'Arizona', 'Azores', 'Dublin', 'London', 'Ljubljana', 'Brussels', 'Bucharest', 'Sofia', 'Bangkok']
        occurrences = Array.new(number_of_occurrences) { Occurrence.new }
        for i in 0..number_of_occurrences-1 do
          Time.zone = zones[i]
          occurrences[i].date = Time.zone.at((first - (i * 10).minutes).to_i)
        end
        occurrences[0], occurrences[5] = occurrences[5], occurrences[0]
        occurrences
      }

      it_behaves_like 'the result looks like [6, 6, 1]'
    end

    context 'when an array of one occurrence is given' do
      let(:occurrences) {
        occurrences = Array.new(1) { Occurrence.new }
        occurrences[0].date = first
        occurrences
      }

      it 'returns an array of length 1' do
        expect(subject.length).to eq 1
      end

      it 'contains a "count" of 1 for each CountPerDate' do
        expect(subject[0].count).to eq 1
      end
    end

    context 'when an empty array is given' do
      let(:occurrences) { Array.new }

      it 'raise an error' do
        expect { subject }.to raise_error NoMethodError
      end
    end

    context 'when nil is given' do
      let(:occurrences) { nil }

      it 'raise an error' do
        expect { subject }.to raise_error NoMethodError
      end
    end
  end
end
