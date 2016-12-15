class AddFactorInstancesToOccurrence < ActiveRecord::Migration
  def change
    change_table :factor_instances do |t|
      t.references :occurrence, index: true
    end
    add_foreign_key :factor_instances, :occurrences
  end
end
