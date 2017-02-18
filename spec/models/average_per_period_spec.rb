require 'rails_helper'

RSpec.describe AveragePerPeriod do
  describe '#initialize' do
    it 'accepts a "symptoms" attribute' do
      symptoms = build_list(:symptom_with_average, 10)
      expect { AveragePerPeriod.new({symptoms: symptoms}) }.not_to raise_error
    end

    it 'accepts a "unit" attribute' do
      expect { AveragePerPeriod.new({unit: 'hour'}) }.not_to raise_error
    end

    it 'accepts "symptoms" and "units" as attributes' do
      symptoms = build_list(:symptom_with_average, 10)
      expect { AveragePerPeriod.new({symptoms: symptoms, unit: 'hour'}) }.not_to raise_error
    end

    it 'accepts an empty attributes set' do
      expect { AveragePerPeriod.new({}) }.not_to raise_error
    end

    it 'accepts no argument' do
      expect { AveragePerPeriod.new }.not_to raise_error
    end
  end

  describe '#symptoms=' do
    before(:each) do
      @average_period = AveragePerPeriod.new
    end

    it 'accepts an array SymptomWithAverage' do
      symptoms = build_list(:symptom_with_average, 10)
      @average_period.symptoms = symptoms
      expect(@average_period.symptoms).to eq symptoms
    end

    it 'accepts nil' do
      expect { @average_period.symptoms = nil }.not_to raise_error
      expect(@average_period.symptoms).to be_nil
    end

    it 'refuses an array of something else than SymptomWthAverage' do
      expect { @average_period.symptoms = ['', 2] }.to raise_error(ArgumentError)
    end
  end

  describe '#unit=' do
    before(:each) do
      @average_period = AveragePerPeriod.new
    end

    it 'accepts "hour" as unit' do
      @average_period.unit = 'hour'
      expect(@average_period.unit).to eq 'hour'
    end

    it 'accepts "day_of_week" as unit' do
      @average_period.unit = 'day_of_week'
      expect(@average_period.unit).to eq 'day_of_week'
    end

    it 'accepts "month" as unit' do
      @average_period.unit = 'month'
      expect(@average_period.unit).to eq 'month'
    end

    it 'accepts "year" as unit' do
      @average_period.unit = 'year'
      expect(@average_period.unit).to eq 'year'
    end

    it 'refuses any other unit' do
      invalid_units = %w(meters celsius second seconds week weeks)
      invalid_units.each do |unit|
        expect { @average_period.unit = unit }.to raise_error(ArgumentError)
      end
    end
  end
end
