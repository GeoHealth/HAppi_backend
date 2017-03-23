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

def import_factors
  open('./db/seeds_data/factors.json') do |factors_file|
    factors_json = JSON.parse factors_file.read
    factors_json.each { |factor_json|
      factor = Factor.new(
          name: factor_json['name'],
          factor_type: factor_json['factor_type']
      )
      factor.save
    }
  end
end

Symptom.delete_all
import_symptoms
Factor.delete_all
import_factors