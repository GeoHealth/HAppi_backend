class DataAnalysis::UsersHavingSameSymptomsController < ApplicationController
  def index
  end

  def new
  end

  def create
    threshold = params.fetch(:analysis).fetch(:threshold)
    system "./fimi03/fim_closed ./fimi03/inputs/chess.dat #{threshold} ./fimi03/outputs/awesome#{threshold}"
    render plain: params[:analysis].inspect
  end
end
