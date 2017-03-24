class Occurrence < ActiveRecord::Base
  belongs_to :symptom
  belongs_to :gps_coordinate
  belongs_to :user
  has_many :factor_instances, dependent: destroy
  has_many :shared_occurrences
  has_many :reports, through: :shared_occurrences

  validates_presence_of :symptom_id
  validates_presence_of :date
  validates_presence_of :user_id

  def as_json(options={})
    super(options.merge(include: [:gps_coordinate, :symptom]))
  end
end
