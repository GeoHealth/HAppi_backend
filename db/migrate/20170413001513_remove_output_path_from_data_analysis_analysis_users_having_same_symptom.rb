class RemoveOutputPathFromDataAnalysisAnalysisUsersHavingSameSymptom < ActiveRecord::Migration
  def change
    remove_column :data_analysis_analysis_users_having_same_symptoms, :output_path, :string
  end
end
