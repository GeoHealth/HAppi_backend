class CreateFactorInstances < ActiveRecord::Migration
  def change
    create_table :factor_instances do |t|
      t.references :factor, index: true
      t.string :value

      t.timestamps null: false
    end
    add_foreign_key :factor_instances, :factors
  end
end
