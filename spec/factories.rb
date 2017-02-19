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

  # SymptomWithAverages
  factory :symptom_with_average do
    sequence(:id)
    name 'pain'
    averages []
  end

  #Occurrences
  factory :occurrence do
    symptom_id { create(:symptom).id }
    date { Date.new }
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
  end
end