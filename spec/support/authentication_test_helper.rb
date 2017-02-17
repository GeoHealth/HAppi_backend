class AuthenticationTestHelper

  # Create a new valid User and save it in database.
  # Set the headers of the given *request* object.
  # Returns the created user
  def self.set_valid_authentication_headers(request)
    email = 'test@fake.com'
    password = '11112222'
    user = User.new(email: email,
                    provider: 'email',
                    uid: email,
                    password: password,
                    current_sign_in_at: Time.now,
                    last_sign_in_at: Time.now
    )

    user.save

    @auth_headers = user.create_new_auth_token

    request.headers.merge!(@auth_headers)
    return user
  end
end