require 'rails_helper'

RSpec.describe 'data_analysis/users_having_same_symptoms/index.html.erb', type: :view do
  before(:each) do
    assign :analysis, DataAnalysis::AnalysisUsersHavingSameSymptom.all
    render
  end

  it 'shows a the h1' do
    assert_select 'h1', 'DataAnalysis - Number of users having same symptoms'
  end
end
