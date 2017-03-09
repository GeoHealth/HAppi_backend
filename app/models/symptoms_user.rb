class SymptomsUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :symptom

  validates_presence_of :user_id
  validates_presence_of :symptom_id
end
