class SymptomsCountsFactory
  def self.build_for(user, start_date = Time.at(0), end_date = Time.current, unit = 'days', symptoms = nil)
    unit = unit || 'days'
    case unit
      when 'hours'
        per_hours_for_user user, start_date, end_date, symptoms
      when 'days'
        per_days_for_user user, start_date, end_date, symptoms
      when 'months'
        per_months_for_user user, start_date, end_date, symptoms
      when 'years'
        per_years_for_user user, start_date, end_date, symptoms
    end
  end

  def self.per_hours_for_user(user, start_date = Time.at(0), end_date = Time.current, symptoms = nil)
    symptoms_count = SymptomsCounts.new
    start_date, end_date = get_default_value_if_nil(start_date, end_date)
    symptoms_count.unit = 'hours'
    symptoms = symptoms || get_symptoms_ids_for_user(user)
    symptoms_count.symptoms = Array.new
    symptoms.each do |id|
      symptoms_count.symptoms.push(SymptomCountFactory.per_hours(id, user.id, start_date, end_date))
    end

    symptoms_count
  end

  def self.per_days_for_user(user, start_date, end_date, symptoms)
    # code here
  end

  def self.per_months_for_user(user, start_date, end_date, symptoms)
    # code here
  end

  def self.per_years_for_user(user, start_date, end_date, symptoms)
    # code here
  end

  private_class_method def self.get_default_value_if_nil(start_date, end_date)
    start_date = start_date || Time.at(0)
    end_date = end_date || Time.current
    return start_date, end_date
  end

  private_class_method def self.get_symptoms_ids_for_user(user)
    Symptom.where(occurrences: {user: user}).includes(:occurrences).uniq.ids
  end
end