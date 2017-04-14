require 'rails_helper'

RSpec.describe DataAnalysis::BasisAnalysis, type: :model do
  describe 'attributes' do
    it {should validate_presence_of(:threshold)}
    it {should validate_presence_of(:status)}

    it {should validate_inclusion_of(:status).in_array(%w( created running done aborted dead ))}
  end

  describe 'after save' do
    before(:each) do
      @analysis = build(:basis_analysis)
      @analysis.save
    end

    it 'has a generated token' do
      expect(@analysis.token).not_to be_nil
    end
  end
end
