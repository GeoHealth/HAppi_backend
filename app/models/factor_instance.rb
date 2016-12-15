class FactorInstance < ActiveRecord::Base
  belongs_to :factor
  belongs_to :occurrence
end
