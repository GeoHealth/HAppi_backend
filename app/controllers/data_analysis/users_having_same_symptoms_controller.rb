class DataAnalysis::UsersHavingSameSymptomsController < ApplicationController
  def index
  end

  def new
  end

  def create

    render plain: params[:analysis].inspect
  end
end
