class SymptomCountFactory
  # @param [integer] symptom_id the ID of the symptom to retrieve
  # @param [integer] user_id the ID of the user
  # @param [DateTime] start_date all occurrences before this date are ignored
  # @param [DateTime] end_date all occurrences after this date are ignored
  # @return [Symptom] a symptom including occurrences
  def self.get_symptom (symptom_id, user_id, start_date, end_date)
    Symptom.includes(:occurrences)
        .where('occurrences.user_id = :user_id AND occurrences.date BETWEEN :start_date AND :end_date',
               {user_id: user_id, start_date: start_date, end_date: end_date})
        .references(nil)
        .find(symptom_id)
  end

  # @param [integer] symptom_id the ID of the symptom to retrieve
  # @param [integer] user_id the ID of the user
  # @param [DateTime] start_date all occurrences before this date are ignored. Default value is original Epoch (1 January 1970).
  # @param [DateTime] end_date all occurrences after this date are ignored. Default value is the current time.
  # @return [SymptomCount]
  def self.per_hours (symptom_id, user_id, start_date = Time.at(0), end_date= Time.current)
    symptom_count = SymptomCount.new
    symptom = get_symptom(symptom_id, user_id, start_date, end_date)

    symptom_count.id = symptom.id
    symptom_count.name = symptom.name
    symptom_count.counts = CountPerDateFactory.per_hour(symptom.occurrences)

    symptom_count
  end
end