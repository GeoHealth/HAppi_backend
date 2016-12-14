class CreateGpsCoordinates < ActiveRecord::Migration
  def change
    create_table :gps_coordinates do |t|
      t.float :accuracy
      t.float :altitude
      t.float :altitude_accuracy
      t.float :heading
      t.float :speed
      t.float :latitude
      t.float :longitude

      t.timestamps null: false
    end
  end
end
