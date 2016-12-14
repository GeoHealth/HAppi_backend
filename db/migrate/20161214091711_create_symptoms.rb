class CreateSymptoms < ActiveRecord::Migration
  def change
    create_table :symptoms do |t|
      t.string :name
      t.string :short_description
      t.string :long_description
      t.string :gender_filter

      t.timestamps null: false
    end
  end
end
