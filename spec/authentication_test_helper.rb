class AuthenticationTestHelper

  # Create a new valid User and save it in database.
  # Set the headers of the given *request* object.
  # Returns the created user
  def self.set_valid_authentication_headers(request)
    email = 'mail@fake.com'
    password = '11112222'
    user = User.new(email: email,
                    provider: 'email',
                    uid: email,
                    encrypted_password: User.new.send(:password_digest, password),
                    password: password,
                    current_sign_in_at: Time.now,
                    last_sign_in_at: Time.now
    )

    user.save

    @auth_headers = user.create_new_auth_token

    request.env['access-token'] = @auth_headers['access-token']
    request.env['token-type'] = @auth_headers['token-type']
    request.env['client'] = @auth_headers['client']
    request.env['expiry'] = @auth_headers['expiry']
    request.env['uid'] = @auth_headers['uid']
    return user
  end
end