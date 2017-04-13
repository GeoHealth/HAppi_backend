class DataAnalysis::UsersHavingSameSymptomsController < ApplicationController
  def index
  end

  def new
  end

  def create
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptomFactory.build_from_params(params[:analysis])
    if @analysis.save
      render @analysis
    else
      render plain: @analysis.errors, status: 404
    end
    # system "./fimi03/fim_closed ./fimi03/inputs/chess.dat #{threshold} ./fimi03/outputs/awesome#{threshold}"
    # render plain: params[:analysis].inspect
  end
end
