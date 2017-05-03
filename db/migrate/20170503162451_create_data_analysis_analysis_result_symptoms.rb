class CreateDataAnalysisAnalysisResultSymptoms < ActiveRecord::Migration
  def change
    create_table :data_analysis_analysis_result_symptoms do |t|
      t.belongs_to :data_analysis_analysis_result, index: {:name => 'index_data_analysis_analysis_result'}
      t.belongs_to :symptom, index: true
    end
  end
end
