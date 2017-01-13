def import_symptoms
  open('./db/seeds_data/symptoms.json') do |symptoms_file|
    symptoms_json = JSON.parse symptoms_file.read
    symptoms_json.each { |symptom_json|
      symptom = Symptom.new(
          name: symptom_json['name'],
          gender_filter: symptom_json['sex_filter']
      )
      symptom.save
    }
  end
end

Symptom.delete_all
import_symptoms