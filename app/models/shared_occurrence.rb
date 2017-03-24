class SharedOccurrence < ActiveRecord::Base
  belongs_to :occurrence
  belongs_to :report

  validates_presence_of :reports_id
  validates_presence_of :occurrences_id
end
