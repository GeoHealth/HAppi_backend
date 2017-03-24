def import_symptoms
  open('./db/seeds_data/symptoms.json') do |symptoms_file|
    symptoms_json = JSON.parse symptoms_file.read
    symptoms_json.each { |symptom_json|
      symptom = Symptom.new(
          id: symptom_json['id'],
          name: symptom_json['name'],
          gender_filter: symptom_json['sex_filter']
      )
      begin
        symptom.save
      rescue ActiveRecord::RecordNotUnique
        puts "Symptom with id #{symptom.id} already exist. Skipped!"
      end
    }
  end
end

def import_factors
  open('./db/seeds_data/factors.json') do |factors_file|
    factors_json = JSON.parse factors_file.read
    factors_json.each { |factor_json|
      factor = Factor.new(
          id: factor_json['id'],
          name: factor_json['name'],
          factor_type: factor_json['factor_type']
      )
      begin
      factor.save
      rescue ActiveRecord::RecordNotUnique
        puts "Factor with id #{factor.id} already exist. Skipped!"
      end
    }
  end
end

import_symptoms
import_factors