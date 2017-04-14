class DropDataAnalysisAnalysisUsersHavingSameSymptoms < ActiveRecord::Migration
  def change
    drop_table :data_analysis_analysis_users_having_same_symptoms
  end
end
