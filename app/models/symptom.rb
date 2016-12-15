class Symptom < ActiveRecord::Base

  validates_presence_of :name
  validates_inclusion_of :gender_filter, in: %w( male female both )
end
