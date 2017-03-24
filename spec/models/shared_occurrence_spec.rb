require 'rails_helper'

RSpec.describe SharedOccurrence, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:reports_id) }
    it { should validate_presence_of(:occurrences_id) }
  end
end
