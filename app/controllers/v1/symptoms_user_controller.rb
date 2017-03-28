class  V1::SymptomsUserController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  def index
    result = Symptom.where(id: SymptomsUser.where(user_id: current_user.id).pluck(:symptom_id))
    render json: {symptoms: result}
  end

  def create
    begin
      symptoms_user = SymptomsUserFactory.build_symptoms_user_from_params(params.fetch(:symptom_id), current_user)
      symptoms_user.save
      render json: symptoms_user
    rescue *[ActiveRecord::InvalidForeignKey, ActionController::ParameterMissing, ActiveRecord::RecordNotUnique]
      render :nothing => true, status: 422
    end
  end

  def destroy
    begin
      symptoms_user = SymptomsUser.find_by(user_id: current_user.id, symptom_id: params.fetch(:symptom_id))
      symptoms_user.destroy
      render json: symptoms_user
    rescue *[NoMethodError, ActionController::ParameterMissing]
      render :nothing => true, status: 422
    end
  end
end
