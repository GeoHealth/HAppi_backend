class SymptomsUserFactory
  def self.build_symptoms_user_from_params(symptom_id, user)
  symptoms_user = SymptomsUser.new
  symptoms_user.symptom_id = symptom_id
  symptoms_user.user_id = user.id
  symptoms_user
  end
end