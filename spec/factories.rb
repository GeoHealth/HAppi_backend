FactoryGirl.define do
  # Sequences
  sequence :email do |n|
    "person#{n}@example.com"
  end

  # Symptoms
  factory :symptom do
    sequence(:id)
    name 'Abdominal pain'
    gender_filter 'both'
  end

  #Occurrences
  factory :occurrence do
    symptom_id { create(:symptom).id }
    date { Time.now }
    user_id { create(:user).id }
  end

  factory :occurrence_with_gps_coordinates, parent: :occurrence do
    association :gps_coordinate, factory: :gps_coordinate, strategy: :build
  end

  factory :occurrence_with_non_existing_symptom, parent: :occurrence do
    symptom_id -1
  end

  factory :occurrence_with_non_existing_user, parent: :occurrence do
    user_id -1
  end

  factory :occurrence_with_3_factor_instances, parent: :occurrence do
    factor_instances { create_list(:factor_instance, 3) }
  end

  # GPSCoordinates
  factory :gps_coordinate do
    latitude 50.663856999985
    longitude 4.6251496
    altitude 25.3
  end

  # Users
  factory :user do
    provider 'email'
    uid { generate(:email) }
    email { uid }
    password '11112222'
    first_name 'Foo'
    last_name 'Bar'
  end

  # CountPerDate
  factory :count_per_date do
    date { Time.now }
    count 1
  end

  # SymptomCount
  factory :symptom_count do
    id { create(:symptom).id }
    name 'name'
    counts { create_list(:count_per_date, 5) }
  end

  # SymptomsUser
  factory :symptoms_user do
    user_id { create(:user).id }
    symptom_id { create(:symptom).id }
  end

  # Report
  factory :report do
    email { generate(:email) }
    expiration_date { Time.now + 2.weeks }
    start_date { Time.now - 2.weeks }
    end_date { Time.now }
    user_id { create(:user).id }
  end

  factory :factor do
    name 'Foo'
    factor_type 'Bar'
  end

  # FactorInstances
  factory :factor_instance do
    factor { create(:factor) }
    value 'some value'
  end

  # DataAnalysis::BasisAnalysis
  factory :basis_analysis, class: DataAnalysis::BasisAnalysis do
    threshold     1000
    status        'created'
  end

  # DataAnalysis::AnalysisUsersHavingSameSymptom
  factory :analysis_users_having_same_symptom, class: DataAnalysis::AnalysisUsersHavingSameSymptom do
    start_date    { Time.now - 2.days }
    end_date      { Time.now }
    threshold     1000
    status        'created'
  end
end