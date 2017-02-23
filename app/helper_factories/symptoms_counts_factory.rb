class SymptomsCountsFactory
  def self.per_hour_for_user(user, start_date = Time.at(0), end_date= Time.current, unit = 'days', symptoms = nil)
    symptoms_count = SymptomsCounts.new
    symptoms_count.unit = unit
    symptoms = symptoms || get_symptoms_ids_for_user(user)
    symptoms_count.symptoms = Array.new
    symptoms.each do |id|
      symptoms_count.symptoms.push(SymptomCountFactory.per_hour(id, user.id, start_date, end_date))
    end

    symptoms_count
  end

  def self.get_symptoms_ids_for_user(user)
    Symptom.where(occurrences: {user: user}).includes(:occurrences).uniq.ids
  end
end