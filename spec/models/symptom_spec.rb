require 'rails_helper'

RSpec.describe Symptom, type: :model do

    describe "attributes" do
        it "should have a name" do
            expect(Symptom.new(name:'Abdominal distension')).to be_valid
        end
    end

end
