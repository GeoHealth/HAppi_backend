class CreateDataAnalysisBasisAnalyses < ActiveRecord::Migration
  def change
    create_table :data_analysis_basis_analyses do |t|
      t.integer :threshold
      t.string :token
      t.string :status
      t.string :type

      t.timestamps null: false
    end
  end
end
