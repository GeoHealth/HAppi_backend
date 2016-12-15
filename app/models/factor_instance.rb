class FactorInstance < ActiveRecord::Base
  belongs_to :factor
  belongs_to :occurrence

  validates_presence_of :factor_id
  validates_presence_of :value
end
