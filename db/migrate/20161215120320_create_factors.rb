class CreateFactors < ActiveRecord::Migration
  def change
    create_table :factors do |t|
      t.string :name
      t.string :type

      t.timestamps null: false
    end
  end
end
