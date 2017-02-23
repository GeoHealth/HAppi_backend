
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