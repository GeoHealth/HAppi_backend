class OccurrencesController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create
    @occurrence = OccurrenceFactory.build_from_params(params[:occurrence])
    @occurrence.user = current_user
    begin
      if @occurrence.save
        render json: @occurrence, status: 201
      else
        render :nothing => true, status: 422
      end
    rescue ActiveRecord::InvalidForeignKey
      render :nothing => true, status: 422
    end
  end
end
