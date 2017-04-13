require 'rails_helper'

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
    context 'when a json analysis with threshold, start_date and end_date is given' do
      before(:each) do
        @valid_analysis = {
            start_date: '2017-02-25 10:10:00',
            end_date: '2017-04-13 20:10:00',
            threshold: 1000
        }

        post :create, analysis: @valid_analysis.as_json
      end

      it 'redirects to analysis_url(@analysis)' do
        expect(response).to redirect_to analysis_users_having_same_symptom_url(assigns(:analysis))
      end

    end

  end
end
