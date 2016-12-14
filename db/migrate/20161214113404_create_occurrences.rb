class CreateOccurrences < ActiveRecord::Migration
  def change
    create_table :occurrences do |t|
      t.references :symptom, index: true
      t.string :date
      t.references :gps_coordinate, index: true

      t.timestamps null: false
    end
    add_foreign_key :occurrences, :symptoms
    add_foreign_key :occurrences, :gps_coordinates
  end
end
