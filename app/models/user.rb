class User < ActiveRecord::Base
  # Include default devise modules.
  # notice that :omniauthable is not included in this block
  # notice that :confirmable is not included in this block
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable

  # note that this include statement comes AFTER the devise block above
  include DeviseTokenAuth::Concerns::User

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
