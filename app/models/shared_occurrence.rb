class SharedOccurrence < ActiveRecord::Base
  belongs_to :occurrence
  belongs_to :report

  validates_presence_of :report_id
  validates_presence_of :occurrence_id
end
