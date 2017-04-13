class DataAnalysis::UsersHavingSameSymptomsController < ApplicationController
  def index
  end

  def new
  end

  def create
    @analysis = DataAnalysis::AnalysisUsersHavingSameSymptom.new(analysis_params)
    @analysis.status = 'created'
    if @analysis.save
      render json: @analysis
    else
      render plain: @analysis.errors.inspect, status: 404
    end
    # system "./fimi03/fim_closed ./fimi03/inputs/chess.dat #{threshold} ./fimi03/outputs/awesome#{threshold}"
    # render plain: params[:analysis].inspect
  end

  def show
  end

  private
  def analysis_params
    params.require(:analysis).permit(:start_date, :end_date, :threshold)
  end
end
