def create_symptom_and_occurrences_for_spec_per_hours (number_of_symptoms_to_create = 1, user = nil)
  user = user || create(:user)
  symptoms = create_list(:symptom, number_of_symptoms_to_create)
  january_2005_10_o_clock = Time.zone.parse('2005-01-01 10:00:00')
  one_hour_later = january_2005_10_o_clock + 1.hour
  two_hours_later = january_2005_10_o_clock + 2.hour
  symptoms.each do |symptom|
    # 3 occurrences at 01-01-2005, 10:00:00
    create_list(:occurrence, 3, {symptom_id: symptom.id, date: january_2005_10_o_clock, user_id: user.id})
    # 2 occurrences at 01-01-2005, 11:00:00
    create_list(:occurrence, 2, {symptom_id: symptom.id, date: one_hour_later, user_id: user.id})
    # 1 occurrence at 01-01-2005, 12:00:00
    create(:occurrence, symptom_id: symptom.id, date: two_hours_later, user_id: user.id)
  end

  return user, symptoms, january_2005_10_o_clock, one_hour_later, two_hours_later
end

def create_symptom_and_occurrences_for_spec_per_days (number_of_symptoms_to_create = 1, user = nil)
  user = user || create(:user)
  symptoms = create_list(:symptom, number_of_symptoms_to_create)
  january_2005_10_o_clock = Time.zone.parse('2005-01-01 10:00:00')
  one_day_later = january_2005_10_o_clock + 1.day
  two_days_later = january_2005_10_o_clock + 2.days
  symptoms.each do |symptom|
    # 3 occurrences at 01-01-2005, 10:00:00
    create_list(:occurrence, 3, {symptom_id: symptom.id, date: january_2005_10_o_clock, user_id: user.id})
    # 2 occurrences at 02-01-2005, 10:00:00
    create_list(:occurrence, 2, {symptom_id: symptom.id, date: one_day_later, user_id: user.id})
    # 1 occurrence at 03-01-2005, 10:00:00
    create(:occurrence, symptom_id: symptom.id, date: two_days_later, user_id: user.id)
  end

  return user, symptoms, january_2005_10_o_clock, one_day_later, two_days_later
end

def create_symptom_and_occurrences_for_spec_per_months (number_of_symptoms_to_create = 1, user = nil)
  user = user || create(:user)
  symptoms = create_list(:symptom, number_of_symptoms_to_create)
  january_2005_10_o_clock = Time.zone.parse('2005-01-01 10:00:00')
  one_month_later = january_2005_10_o_clock + 1.month
  two_months_later = january_2005_10_o_clock + 2.months
  symptoms.each do |symptom|
    # 3 occurrences at 01-01-2005, 10:00:00
    create_list(:occurrence, 3, {symptom_id: symptom.id, date: january_2005_10_o_clock, user_id: user.id})
    # 2 occurrences at 01-02-2005, 10:00:00
    create_list(:occurrence, 2, {symptom_id: symptom.id, date: one_month_later, user_id: user.id})
    # 1 occurrence at 01-03-2005, 10:00:00
    create(:occurrence, symptom_id: symptom.id, date: two_months_later, user_id: user.id)
  end

  return user, symptoms, january_2005_10_o_clock, one_month_later, two_months_later
end

def create_symptom_and_occurrences_for_spec_per_years (number_of_symptoms_to_create = 1, user = nil)
  user = user || create(:user)
  symptoms = create_list(:symptom, number_of_symptoms_to_create)
  january_2005_10_o_clock = Time.zone.parse('2005-01-01 10:00:00')
  one_year_later = january_2005_10_o_clock + 1.year
  two_years_later = january_2005_10_o_clock + 2.years
  symptoms.each do |symptom|
    # 3 occurrences at 01-01-2005, 10:00:00
    create_list(:occurrence, 3, {symptom_id: symptom.id, date: january_2005_10_o_clock, user_id: user.id})
    # 2 occurrences at 01-01-2006, 10:00:00
    create_list(:occurrence, 2, {symptom_id: symptom.id, date: one_year_later, user_id: user.id})
    # 1 occurrence at 01-01-2007, 10:00:00
    create(:occurrence, symptom_id: symptom.id, date: two_years_later, user_id: user.id)
  end

  return user, symptoms, january_2005_10_o_clock, one_year_later, two_years_later
end


RSpec.shared_examples 'verify unit, number of symptoms, number of counts and number of count' do |unit, number_of_symptoms, number_of_counts, number_of_count_in_each_count_per_date|
  it "has a unit = '#{unit}'" do
    expect(subject.unit).to eq unit
  end

  it "has #{number_of_symptoms} symptoms" do
    expect(subject.symptoms.length).to eq number_of_symptoms
  end

  describe 'each symptom' do
    it "has #{number_of_counts} CountPerDate" do
      subject.symptoms.each do |symptom_count|
        expect(symptom_count.counts.length).to eq number_of_counts
      end
    end

    describe 'each CountPerDate' do
      it "has a count = #{number_of_count_in_each_count_per_date}" do
        subject.symptoms.each do |symptom_count|
          symptom_count.counts.each_with_index do |count_per_date, index|
            expect(count_per_date.count).to eq number_of_count_in_each_count_per_date.fetch(index)
          end
        end
      end
    end
  end
end

RSpec.shared_examples 'different values for symptoms parameter' do |unit, number_of_symptoms, number_of_counts, number_of_count_in_each_count_per_date|
  context 'with an undefined symptoms parameter' do
    let(:symptoms) { nil }

    include_examples 'verify unit, number of symptoms, number of counts and number of count', unit, number_of_symptoms, number_of_counts, number_of_count_in_each_count_per_date
  end

  context 'with a symptoms parameter that contains the 2 symptoms explicitly' do
    let(:symptoms) { [@symptoms[0].id, @symptoms[1].id] }

    include_examples 'verify unit, number of symptoms, number of counts and number of count', unit, number_of_symptoms, number_of_counts, number_of_count_in_each_count_per_date
  end

  context 'with a symptoms parameter that contains only 1 symptom' do
    let(:symptoms) { [@symptoms[1].id] }

    include_examples 'verify unit, number of symptoms, number of counts and number of count', unit, number_of_symptoms == 0 ? 0 : 1, number_of_counts, number_of_count_in_each_count_per_date
  end

  context 'with an invalid symptoms parameter' do
    let(:symptoms) { [-1] }

    include_examples 'verify unit, number of symptoms, number of counts and number of count', unit, 0, 0, nil
  end
end