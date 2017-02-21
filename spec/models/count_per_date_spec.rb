require 'rails_helper'
require 'support/have_attr_accessor'

RSpec.describe CountPerDate do

  describe 'attributes' do
    subject(:count_per_date) { build(:count_per_date) }

    it { should have_attr_accessor(:date) }

    it { should have_attr_accessor(:count) }
  end
end
