class CreateDataAnalysisAnalysisUsersHavingSameSymptoms < ActiveRecord::Migration
  def change
    create_table :data_analysis_analysis_users_having_same_symptoms do |t|
      t.timestamp :start_date
      t.timestamp :end_date
      t.integer :threshold
      t.string :token
      t.string :output_path
      t.string :status

      t.timestamps null: false
    end
  end
end
