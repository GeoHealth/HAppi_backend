require 'rails_helper'
require 'support/have_attr_accessor'

RSpec.describe SymptomCount do
  it { should have_attr_accessor(:id) }

  it { should have_attr_accessor(:name) }

  it { should have_attr_accessor(:counts) }
end
