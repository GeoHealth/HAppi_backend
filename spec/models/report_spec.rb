require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'attributes' do
    it { should validate_presence_of(:email) }

    it { should validate_presence_of(:expiration_date) }

    it { should validate_presence_of(:user_id) }

    it { should validate_presence_of(:start_date) }

    it { should validate_presence_of(:end_date) }
  end

  describe 'after save' do
    before(:each) do
      @report = build(:report)
      @report.save
    end

    it 'has a generated token' do
      expect(@report.token).not_to be_nil
    end
  end

  describe '.enhanceReportWithSymptoms' do
    context 'with a report associated to zero occurrences' do
      before(:each) do
        @original_report = create(:report)
        @returned_report = @original_report.enhanceReportWithSymptoms
      end

      it 'returns an instance of Report' do
        expect(@returned_report).to be_instance_of Report
      end

      it 'returns the same object (self)' do
        expect(@returned_report).to eql @original_report
      end

      it 'contains a "symptoms" array' do
        expect(@returned_report).to have_attributes ({:symptoms => []})
      end
    end
  end

  context 'with a report associated to 10 occurrences of the same symptom' do
    before(:each) do
      # create a first user, with a symptom and some occurrences
      @user = create(:user)
      @symptom = create(:symptom)
      @occurrences_associated_to_report = create_list(:occurrence_with_3_factor_instances, 10, user_id: @user.id, symptom_id: @symptom.id)
      @other_occurrences = create_list(:occurrence_with_3_factor_instances, 10, user_id: @user.id, symptom_id: @symptom.id)
      # create a second user, with another symptom and some occurrences of both symptoms
      @other_user = create(:user)
      @other_symptom = create(:symptom)
      create_list(:occurrence_with_3_factor_instances, 10, user_id: @other_user.id, symptom_id: @symptom.id)
      create_list(:occurrence_with_3_factor_instances, 10, user_id: @other_user.id, symptom_id: @other_symptom.id)
      create_list(:occurrence_with_3_factor_instances, 10, user_id: @other_user.id, symptom_id: @other_symptom.id)

      @original_report = create(:report, user_id: @user.id)
      @original_report.occurrences << @occurrences_associated_to_report
      @returned_report = @original_report.enhanceReportWithSymptoms
    end

    describe 'the array of symptoms' do
      it 'contains the symptom associated to the occurrences in the report' do
        expect(@returned_report.symptoms.length).to eq 1
        expect(@returned_report.symptoms).to include @symptom
      end

      describe 'the symptom' do
        it 'contains only the occurrences associated to the report' do
          symptom = @returned_report.symptoms[0]
          expect(symptom.occurrences.length).to eq @occurrences_associated_to_report.length
          @occurrences_associated_to_report.each do |occurrence|
            expect(symptom.occurrences.ids).to include occurrence.id
          end
        end
      end

      describe 'each occurrence' do
        it 'has an array of 3 factor instances' do
          @returned_report.symptoms.each do |symptom|
            symptom.occurrences.each do |occurrence|
              expect(occurrence.factor_instances.length).to eq 3
            end
          end
        end
      end
    end
  end

end
