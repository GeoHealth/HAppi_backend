class OccurrencesController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def create
    @occurrence = OccurrenceFactory.build_from_params(params[:occurrence])
    begin
      if @occurrence.save
        render json: @occurrence, status: 201
      else
        render json: @occurrence, status: 422
      end
    rescue ActiveRecord::InvalidForeignKey
      render json: @occurrence, status: 422
    end
  end
end
