require 'rails_helper'

RSpec.describe SymptomsUserFactory do
  describe '.build_symptoms_user_from_params' do
    subject { SymptomsUserFactory.build_symptoms_user_from_params symptom_id, user }

    context 'when the given parameters are correct' do
      before(:each) do
        @valid_symptoms_user = build(:symptoms_user)
        @user = build(:user)
      end

      let(:symptom_id) { @valid_symptoms_user.symptom_id }
      let(:user) {@user}

      it 'returns an instance of SymptomsUser' do
        expect(subject).to be_an_instance_of(SymptomsUser)
      end

      it 'returns an object with the correct user_id and symptom_id' do
        expect(subject.user_id).to eq @user.id
        expect(subject.symptom_id).to eq @valid_symptoms_user.symptom_id
      end
    end
  end
end