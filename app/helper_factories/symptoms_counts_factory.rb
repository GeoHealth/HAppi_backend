class SymptomsCountsFactory
  def self.build_for(user_id, start_date, end_date, unit = 'days', symptoms = nil)
    unit = unit || 'days'
    start_date, end_date, symptoms, symptoms_count = initialize_symptoms_counts(user_id, start_date, end_date, symptoms, unit)
    symptoms.each do |id|
      begin
        symptoms_count.symptoms.push(SymptomCountFactory.build_for(id, user_id, start_date, end_date, unit))
      rescue
      end
    end
    symptoms_count
  end

  private_class_method def self.get_symptoms_ids_for_user_id(user_id)
                         Symptom.where(occurrences: {user_id: user_id}).includes(:occurrences).uniq.ids
                       end

  private_class_method def self.initialize_symptoms_counts(user_id, start_date, end_date, symptoms, unit)
                         symptoms_count = SymptomsCounts.new
                         symptoms_count.unit = unit
                         symptoms = symptoms || get_symptoms_ids_for_user_id(user_id)
                         symptoms_count.symptoms = Array.new
                         return start_date, end_date, symptoms, symptoms_count
                       end
end