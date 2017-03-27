class Report < ActiveRecord::Base
  has_secure_token

  has_many :shared_occurrences
  has_many :occurrences, through: :shared_occurrences
  belongs_to :user

  validates_presence_of :email
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :expiration_date
  validates_presence_of :token
  validates_presence_of :user_id
end
