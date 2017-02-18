class AverageStatsFactory
  def self.per_hour_for_user(user)
    symptoms = Symptom.includes(:occurrences).where(occurrences: {user_id: user.id})
    # TODO compute average
    # Comment calculer la moyenne? Pour chaque symptome, on compterait le nombre d'occurrences et on le diviserait par le nombre de jour entre la 1ere apparition de l'occurrence et la dernière apparition de l'occurrence

    symptoms_average = Array.new(symptoms.length) { SymptomWithAverage.new }
    symptoms.each_with_index do |symptom, index|
      symptoms_average[index].averages = []
    end

    average = AveragePerPeriod.new({unit: 'hour', symptoms: symptoms_average})
    return average
  end
end