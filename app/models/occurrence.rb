class Occurrence < ActiveRecord::Base
  belongs_to :symptom
  belongs_to :gps_coordinate
  belongs_to :user
  has_many :factor_instances

  validates_presence_of :symptom_id
  validates_presence_of :date
  validates_presence_of :user_id

  def as_json(options={})
    super(options.merge(:include => [:gps_coordinate]))
  end
end
