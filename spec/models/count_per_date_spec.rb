require 'rails_helper'
require 'support/have_attr_accessor'

RSpec.describe CountPerDate do
  describe 'attributes' do
    it { should have_attr_accessor(:date) }

    it { should have_attr_accessor(:count) }
  end

  describe '#initialize' do
    it 'start initiziale count to 0' do
      expect(CountPerDate.new.count).to eq 0
    end
  end
end
