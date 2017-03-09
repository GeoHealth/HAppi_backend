require 'rails_helper'
require 'support/have_attr_accessor'

RSpec.describe SymptomsUser do
  it {should validate_presence_of(:user_id)}
  it {should validate_presence_of(:symptom_id)}
end