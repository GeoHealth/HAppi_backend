class SymptomsUserController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
    result = Symptom.where(id: SymptomsUser.where(user_id: current_user.id).pluck(:symptom_id))
    render json: {'symptoms': result}
  end

end
