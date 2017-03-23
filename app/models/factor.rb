class Factor < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :factor_type
end
