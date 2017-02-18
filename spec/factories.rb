FactoryGirl.define do
  factory :symptom do
    name 'Abdominal pain'
    gender_filter 'both'
  end

  factory :occurrence do
    symptom_id { create(:symptom).id }
    user_id { create(:user).id }
    date { Date.new }
  end

  factory :occurrence_with_non_existing_symptom, class: Occurrence do
    symptom_id -1
    user_id { create(:user).id }
    date { Date.new }
  end

  factory :occurrence_with_gps_coordinates, parent: :occurrence do
    association :gps_coordinate, factory: :gps_coordinate, strategy: :build
  end

  factory :occurrence_with_non_existing_user, class: Occurrence do
    symptom_id { create(:symptom).id }
    user_id -1
    date { Date.new }
  end

  factory :gps_coordinate do
    latitude 50.663856999985
    longitude 4.6251496
    altitude 25.3
  end

  factory :user do
    provider 'email'
    uid 'fake@mail.com'
    email 'fake@mail.com'
    password '11112222'
    current_sign_in_at Time.now
    last_sign_in_at Time.now
  end

  factory :symptom_with_average do
    sequence(:id)
    name 'pain'
    averages []
  end
end