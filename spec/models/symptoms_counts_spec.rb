require 'rails_helper'
require 'support/have_attr_accessor'

RSpec.describe SymptomsCounts do
  it { should have_attr_accessor(:symptoms) }

  it { should have_attr_accessor(:unit) }
end
