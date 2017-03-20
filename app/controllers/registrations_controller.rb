class RegistrationsController < DeviseTokenAuth::RegistrationsController
  private

  def sign_up_params
    params.permit(:first_name, :last_name, :gender, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.permit(:first_name, :last_name, :gender, :email, :password, :password_confirmation, :current_password)
  end
end