require 'rails_helper'

RSpec.describe AveragePerPeriod do
  describe '#initialize' do
    it 'accepts an "id" attribute' do
      expect { SymptomWithAverage.new({id: 1}) }.not_to raise_error
    end

    it 'accepts a "name" attribute' do
      expect { SymptomWithAverage.new({name: 'name'}) }.not_to raise_error
    end

    it 'accepts an "averages" attribute' do
      expect { SymptomWithAverage.new({averages: [1,2]}) }.not_to raise_error
    end

    it 'accepts "id" and "name" as attributes' do
      expect { SymptomWithAverage.new({id: 1, name: 'name'}) }.not_to raise_error
    end

    it 'accepts "id" and "averages" as attributes' do
      expect { SymptomWithAverage.new({id: 1, averages: [1,2]}) }.not_to raise_error
    end

    it 'accepts "name" and "averages" as attributes' do
      expect { SymptomWithAverage.new({name: 'name', averages: [1,2]}) }.not_to raise_error
    end

    it 'accepts "name" and "averages" as attributes' do
      expect { SymptomWithAverage.new({id: 1, name: 'name', averages: [1,2]}) }.not_to raise_error
    end

    it 'accepts an empty attributes set' do
      expect { SymptomWithAverage.new({}) }.not_to raise_error
    end

    it 'accepts no argument' do
      expect { SymptomWithAverage.new }.not_to raise_error
    end
  end

  describe '#averages=' do
    before(:each) do
      @symptom_with_average = SymptomWithAverage.new
    end

    it 'accepts an array of Integer' do
      numbers = [1,2,3,4]
      @symptom_with_average.averages = numbers
      expect(@symptom_with_average.averages).to eq numbers
    end

    it 'accepts nil' do
      expect { @symptom_with_average.averages = nil }.not_to raise_error
      expect(@symptom_with_average.averages).to be_nil
    end

    it 'refuses an array of something else than Integer' do
      expect { @symptom_with_average.averages = ['', 2] }.to raise_error(ArgumentError)
    end
  end
end
