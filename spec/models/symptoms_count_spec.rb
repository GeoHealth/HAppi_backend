require 'rails_helper'
require 'support/have_attr_accessor'

RSpec.describe SymptomsCount do
  it { should have_attr_accessor(:symptoms) }

  it { should have_attr_accessor(:unit) }
end
