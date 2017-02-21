require 'rails_helper'

RSpec.describe SymptomCountFactory do
  describe '.get_symptom' do
    before(:each) do
      @user = create(:user)
      @symptom = create(:symptom)
      @january_2005_10_o_clock = Time.zone.parse('2005-01-01 10:00:00')
      @one_hour_later = @january_2005_10_o_clock + 1.hour
      @two_hours_later = @january_2005_10_o_clock + 2.hour
      # 3 occurrences at 01-01-2005, 10:00:00
      create_list(:occurrence, 3, {symptom_id: @symptom.id, date: @january_2005_10_o_clock, user_id: @user.id})
      # 2 occurrences at 01-01-2005, 11:00:00
      create_list(:occurrence, 2, {symptom_id: @symptom.id, date: @one_hour_later, user_id: @user.id})
      # 1 occurrence at 01-01-2005, 12:00:00
      create(:occurrence, symptom_id: @symptom.id, date: @two_hours_later, user_id: @user.id)
    end

    subject { SymptomCountFactory.get_symptom symptom_id, user_id, start_date, end_date }

    context 'with existing symptom_id, user_id' do
      let(:symptom_id) { @symptom.id }
      let(:user_id) { @user.id }

      context 'whith all occurrences within the given interval' do
        let(:start_date) { @january_2005_10_o_clock - 1.day }
        let(:end_date) { @january_2005_10_o_clock + 1.day }

        it 'returns the symptom with its id' do
          expect(subject.id).to eq @symptom.id
        end

        it 'contains 6 occurrences' do
          expect(subject.occurrences.length).to eq 6
        end

        it 'contains occurrences with the correct user_id' do
          subject.occurrences.each do |occurrence|
            expect(occurrence.user_id).to eq @user.id
          end
        end
      end

      context 'with no occurrences within the given interval' do
        let(:start_date) { @january_2005_10_o_clock - 2.day }
        let(:end_date) { @january_2005_10_o_clock - 1.day }

        it 'raises an exception' do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'with 3 occurrences excluded because they are after end_date' do
        let(:start_date) { @january_2005_10_o_clock - 1.day }
        let(:end_date) { @january_2005_10_o_clock + 10.minutes }

        it 'contains 3 occurrences' do
          expect(subject.occurrences.length).to eq 3
        end
      end

      context 'with 3 occurrences excluded because they are before start_date' do
        let(:start_date) { @january_2005_10_o_clock + 10.minutes }
        let(:end_date) { @january_2005_10_o_clock + 1.day }

        it 'contains 3 occurrences' do
          expect(subject.occurrences.length).to eq 3
        end
      end
    end
  end

  describe '.per_hour' do

  end
end
