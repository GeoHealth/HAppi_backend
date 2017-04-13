require 'rails_helper'

RSpec.shared_examples 'creates the analysis and redirect' do | |
  it 'redirects to analysis_url(@analysis)' do
    expect(response).to redirect_to(action: 'show', id: assigns(:analysis).id)
  end

  it 'adds an instance of DataAnalysis::AnalysisUsersHavingSameSymptom to the database' do
    expect(DataAnalysis::AnalysisUsersHavingSameSymptom.count).to eq 1
  end

  it 'saves the given json' do
    saved_instance = DataAnalysis::AnalysisUsersHavingSameSymptom.first
    expect(saved_instance.start_date).to be_within(1.second).of(Time.zone.parse(@start_date))
    expect(saved_instance.end_date).to be_within(1.second).of(Time.zone.parse(@end_date))
    expect(saved_instance.threshold).to eq @threshold
  end

  it 'has the status created' do
    saved_instance = DataAnalysis::AnalysisUsersHavingSameSymptom.first
    expect(saved_instance.status).to eq 'created'
  end

  it 'adds a job to the queue of worker DataAnalysis::AnalysisUsersHavingSameSymptomWorker' do
    expect(DataAnalysis::AnalysisUsersHavingSameSymptomWorker.jobs.size).to eq 1
  end
end

RSpec.describe DataAnalysis::UsersHavingSameSymptomsController, type: :controller do

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'renders index' do
      expect(get :index).to render_template :index
    end
  end

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'renders new' do
      expect(get :new).to render_template :new
    end
  end

  describe 'POST #create' do
    before(:each) do
      @start_date = '2017-02-25 10:10:00'
      @end_date = '2017-04-13 20:10:00'
      @threshold = 1000
    end

    context 'when a json analysis with threshold, (atomic) start_date and (atomic) end_date is given' do
      before(:each) do
        @valid_analysis = {
            start_date: @start_date,
            end_date: @end_date,
            threshold: @threshold
        }

        post :create, analysis: @valid_analysis.as_json
      end

      include_examples 'creates the analysis and redirect'
    end

    context 'when a json analysis with threshold, (atomic) start_date and (atomic) end_date is given' do
      before(:each) do
        @valid_analysis = {
            'start_date(1i)': '2017',
            'start_date(2i)': '02',
            'start_date(3i)': '25',
            'start_date(4i)': '10',
            'start_date(5i)': '10',
            'end_date(1i)': '2017',
            'end_date(2i)': '04',
            'end_date(3i)': '13',
            'end_date(4i)': '20',
            'end_date(5i)': '10',
            threshold: @threshold
        }

        post :create, analysis: @valid_analysis.as_json
      end

      include_examples 'creates the analysis and redirect'
    end

    context 'when an invalid json is given' do
      before(:each) do
        @invalid_analysis = {
            foo: 'bar'
        }

        post :create, analysis: @invalid_analysis.as_json
      end

      it 'returns a 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'does not add an instance of DataAnalysis::AnalysisUsersHavingSameSymptom to the database' do
        expect(DataAnalysis::AnalysisUsersHavingSameSymptom.count).to eq 0
      end

      it 'does not add any job to the queue of worker DataAnalysis::AnalysisUsersHavingSameSymptomWorker' do
        expect(DataAnalysis::AnalysisUsersHavingSameSymptomWorker.jobs.size).to eq 0
      end
    end

  end
end
