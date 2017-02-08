FactoryGirl.define do
  factory :symptom do
    name 'Abdominal pain'
    gender_filter 'both'
  end

  factory :occurrence do
    symptom_id { create(:symptom).id }
    date { Date.new }
  end

  factory :occurrence_with_non_existing_symptom, class: Occurrence do
    symptom_id -1
    date { Date.new }
  end

  factory :occurrence_with_gps_coordinates, parent: :occurrence do
    association :gps_coordinate, factory: :gps_coordinate, strategy: :build
  end

  factory :gps_coordinate do
    latitude 50.663856999985
    longitude 4.6251496
    altitude 25.3
  end
end