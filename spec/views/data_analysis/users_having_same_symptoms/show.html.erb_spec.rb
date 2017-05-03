require 'rails_helper'

RSpec.describe 'data_analysis/users_having_same_symptoms/show.html.erb', type: :view do
  before(:each) do
    results = create(:analysis_results)
    @analysis = results.data_analysis_analysis_users_having_same_symptom
    assign(:analysis, results.data_analysis_analysis_users_having_same_symptom)
  end

  it 'shows the creation date' do
    render
    expect(rendered).to match("Analysis created at #{@analysis.created_at}")
  end

  it 'shows the status' do
    render
    expect(rendered).to match("Status: #{@analysis.status}")
  end

  it 'shows the token' do
    render
    expect(rendered).to match("Token: #{@analysis.token}")
  end

  context 'when the analysis is done' do
    before(:each) do
      @analysis.status = 'done'
      @analysis.save
    end

    context 'when the analysis has 2 results with 2 and 3 symptoms, result_number are 5 and 17 respectively' do
      before(:each) do
        @analysis.data_analysis_analysis_results = []
        symptoms = []
        (1..3).each {|i|
          symptoms << create(:symptom, name: "Symptom#{i}")
        }
        result1 = create(:analysis_results, result_number: 5)
        result2 = create(:analysis_results, result_number: 17)

        result1.symptoms << symptoms
        result2.symptoms << [symptoms[0], symptoms[1]]

        @analysis.data_analysis_analysis_results = [result1, result2]
        @analysis.save
      end

      it 'shows 2 <td>; one with result 15 and 3 symptoms and another with result 17 and 2 symptoms' do
        render
        expect(rendered).to match /<td>5<\/td>
        .*<td>
.*Symptom1 &
.*Symptom2 &
.*Symptom3 &
.*<\/td>/m
        expect(rendered).to match /<td>17<\/td>
        .*<td>
.*Symptom1 &
.*Symptom2 &
.*<\/td>/m
      end
    end
  end

end
