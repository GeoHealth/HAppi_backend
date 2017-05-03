class CreateDataAnalysisAnalysisResults < ActiveRecord::Migration
  def change
    create_table :data_analysis_analysis_results do |t|
      t.integer :result_number
      t.belongs_to :data_analysis_analysis_users_having_same_symptom, index: {:name => 'index_data_analysis_users_having_same_symptom'}
    end
  end
end
