class SymptomCountFactory
  def self.get_symptom (symptom_id, user_id, start_date, end_date)
    Symptom.includes(:occurrences)
        .where('occurrences.user_id = :user_id AND occurrences.date BETWEEN :start_date AND :end_date',
               {user_id: user_id, start_date: start_date, end_date: end_date})
        .references(:occurrences)
        .find(symptom_id)
  end

  # def per_hour (symptom_id, user_id, start_date = Time.new(1970), end_date= Time.now)
  #   symptom_count = SymptomCount.new
  #   symptom = SymptomCountFactory.get_symptom(symptom_id, user_id, start_date, end_date)
  #   symptom_count.id = symptom.id
  #
  #
  #   symptom_count
  # end
end