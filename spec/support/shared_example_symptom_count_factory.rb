def create_symptom_and_occurrences_for_spec (number_of_symptoms_to_create = 1, user = nil)
  user = user || create(:user)
  symptoms = create_list(:symptom, number_of_symptoms_to_create)
  january_2005_10_o_clock = Time.zone.parse('2005-01-01 10:00:00')
  one_hour_later = january_2005_10_o_clock + 1.hour
  two_hours_later = january_2005_10_o_clock + 2.hour
  symptoms.each do |symptom|
    # 3 occurrences at 01-01-2005, 10:00:00
    create_list(:occurrence, 3, {symptom_id: symptom.id, date: january_2005_10_o_clock, user_id: user.id})
    # 2 occurrences at 01-01-2005, 11:00:00
    create_list(:occurrence, 2, {symptom_id: symptom.id, date: one_hour_later, user_id: user.id})
    # 1 occurrence at 01-01-2005, 12:00:00
    create(:occurrence, symptom_id: symptom.id, date: two_hours_later, user_id: user.id)
  end

  return user, symptoms, january_2005_10_o_clock, one_hour_later, two_hours_later
end

RSpec.shared_examples 'all occurrences are included in the given interval' do
  it 'has the correct symptom_id' do
    expect(subject.id).to eq @symptom.id
  end

  it 'has the correct symptom name' do
    expect(subject.name).to eq @symptom.name
  end

  it 'has 3 counts' do
    expect(subject.counts.length).to eq 3
  end

  describe 'the first count' do
    before(:each) do
      @first_count = subject.counts[0]
    end

    it 'is for 10:00:00' do
      expect(@first_count.date).to eq @january_2005_10_o_clock
    end

    it ' has 3 occurrences' do
      expect(@first_count.count).to eq 3
    end
  end

  describe 'the second count' do
    before(:each) do
      @second_count = subject.counts[1]
    end

    it 'is for 11:00:00' do
      expect(@second_count.date).to eq @one_hour_later
    end

    it ' has 2 occurrences' do
      expect(@second_count.count).to eq 2
    end
  end

  describe 'the third count' do
    before(:each) do
      @third_count = subject.counts[2]
    end

    it 'is for 12:00:00' do
      expect(@third_count.date).to eq @two_hours_later
    end

    it ' has 1 occurrence' do
      expect(@third_count.count).to eq 1
    end
  end
end