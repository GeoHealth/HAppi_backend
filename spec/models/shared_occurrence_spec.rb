require 'rails_helper'

RSpec.describe SharedOccurrence, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:report_id) }
    it { should validate_presence_of(:occurrence_id) }
  end
end
