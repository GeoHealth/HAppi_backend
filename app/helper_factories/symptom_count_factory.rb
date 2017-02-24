class SymptomCountFactory
  # Build an instance of SymptomCount for the given symptom_id and containing the occurrences for the given user_id 
  # between start_date and end_date
  # @param [integer] symptom_id
  # @param [integer] user_id
  # @param [ActiveSupport::TimeWithZone] start_date
  # @param [ActiveSupport::TimeWithZone] end_date
  # @param [string] unit [hours, days, months, years]
  def self.build_for (symptom_id, user_id, start_date, end_date, unit)
    symptom = get_symptom(symptom_id, user_id, start_date, end_date)

    symptom_count = SymptomCount.new
    symptom_count.id = symptom.id
    symptom_count.name = symptom.name
    symptom_count.counts = CountPerDateFactory.group_by(symptom.occurrences, start_date, end_date, unit)

    symptom_count
  end

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
end