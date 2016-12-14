class Occurrence < ActiveRecord::Base
  belongs_to :symptom
  belongs_to :gps_coordinate
end
