require 'rails_helper'

RSpec.describe AverageStatsFactory do
  describe '.per_hour_for_user' do
    number_of_symptoms_to_create = 2
    number_of_occurrence_to_create = 10

    before(:each) do
      @user = create(:user)
    end

    before(:each) do
      @symptoms = create_list(:symptom, number_of_symptoms_to_create)
      today = Date.new
      a_week_ago = today - 1.week
      two_weeks_ago = a_week_ago - 1.week
      @symptoms.each do |symptom|
        create_list(:occurrence, number_of_occurrence_to_create, user_id: @user.id, symptom_id: symptom.id, date: today)
        create_list(:occurrence, number_of_occurrence_to_create, user_id: @user.id, symptom_id: symptom.id, date: a_week_ago)
        create_list(:occurrence, number_of_occurrence_to_create, user_id: @user.id, symptom_id: symptom.id, date: two_weeks_ago)
      end
    end

    context 'when a valid user is given' do
      before(:each) do
        @returned_value = AverageStatsFactory.per_hour_for_user @user
      end

      it 'returns an instance of AveragePerPeriod' do
        expect(@returned_value).to be_an AveragePerPeriod
      end

      it 'contains the correct number of symptoms' do
        expect(@returned_value.symptoms.length).to eq number_of_symptoms_to_create
      end

      it 'has a unit equals to "hour"' do
        expect(@returned_value.unit).to eq 'hour'
      end
    end
  end
end
