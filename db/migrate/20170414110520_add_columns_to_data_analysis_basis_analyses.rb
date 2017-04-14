class AddColumnsToDataAnalysisBasisAnalyses < ActiveRecord::Migration
  def change
    add_column :data_analysis_basis_analyses, :start_date, :timestamp
    add_column :data_analysis_basis_analyses, :end_date, :timestamp
  end
end
