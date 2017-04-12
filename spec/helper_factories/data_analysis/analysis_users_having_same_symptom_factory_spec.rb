require 'rails_helper'

RSpec.shared_examples 'check all attributes are the given one' do ||
  it 'returns an instance with all attributes set to the given values' do
    expect(@created_analysis.threshold).to eq(@valid_analysis[:threshold])
    expect(@created_analysis.status).to eq('created')
    expect(@created_analysis.start_date).to be_within(1.second).of (Time.zone.parse(@valid_analysis[:start_date]))
    expect(@created_analysis.end_date).to be_within(1.second).of (Time.zone.parse(@valid_analysis[:end_date]))
  end
end

RSpec.shared_examples 'check all attributes are nil' do ||
  it 'returns an occurrence with all attributes set to nil' do
    expect(@created_analysis.threshold).to be_nil
    expect(@created_analysis.start_date).to be_nil
    expect(@created_analysis.end_date).to be_nil
  end
end

RSpec.shared_examples 'check given instance class' do ||
  it 'returns an instance of DataAnalysis::AnalysisUsersHavingSameSymptom' do
    expect(@created_analysis).to be_an_instance_of(DataAnalysis::AnalysisUsersHavingSameSymptom)
  end
end

RSpec.describe DataAnalysis::AnalysisUsersHavingSameSymptomFactory do

  def check_all_attributes_are_nil
    expect(@created_analysis.threshold).to be_nil
    expect(@created_analysis.start_date).to be_nil
    expect(@created_analysis.end_date).to be_nil
  end

  describe '.build_from_params' do
    before(:each) do
      @valid_analysis = {
          start_date: '2017-02-25 10:10:00',
          end_date: '2017-04-13 20:10:00',
          threshold: 1000
      }
    end

    context 'when a valid json is given' do
      before(:each) do
        @created_analysis = DataAnalysis::AnalysisUsersHavingSameSymptomFactory.build_from_params(@valid_analysis.as_json)
      end

      include_examples 'check given instance class'
      include_examples 'check all attributes are the given one'
    end

    context 'when a valid json is given as a string' do
      before(:each) do
        @created_analysis = DataAnalysis::AnalysisUsersHavingSameSymptomFactory.build_from_params(@valid_analysis.to_json)
      end

      include_examples 'check given instance class'
      include_examples 'check all attributes are the given one'
    end

    context 'when a nil value is given' do
      before(:each) do
        @created_analysis = DataAnalysis::AnalysisUsersHavingSameSymptomFactory.build_from_params(nil)
      end

      include_examples 'check given instance class'
      include_examples 'check all attributes are nil'
    end

    context 'when an invalid json is given' do
      before(:each) do
        @invalid_occurrence = {
            invalid_key: 5
        }
        @created_analysis = DataAnalysis::AnalysisUsersHavingSameSymptomFactory.build_from_params(@invalid_occurrence.as_json)
      end

      include_examples 'check given instance class'
      include_examples 'check all attributes are nil'
    end

    context 'when an invalid json is given as string' do
      before(:each) do
        @invalid_occurrence = {
            invalid_key: 5
        }
        @created_analysis = DataAnalysis::AnalysisUsersHavingSameSymptomFactory.build_from_params(@invalid_occurrence.to_json)
      end

      include_examples 'check given instance class'
      include_examples 'check all attributes are nil'
    end
  end
end
