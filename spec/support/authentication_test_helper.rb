class AuthenticationTestHelper

  # Create a new valid User and save it in database.
  # Set the headers of the given *request* object.
  # Returns the created user
  def self.set_valid_authentication_headers(request)
    # email = 'test@fake.com'
    # password = '11112222'
    user = FactoryGirl.create(:user)
    # user = User.new(email: email,
    #                 provider: 'email',
    #                 uid: email,
    #                 password: password
    # )
    # unless user.save
    #   print "#{user.errors} error"
    # end

    @auth_headers = user.create_new_auth_token
    request.headers.merge!(@auth_headers)
    return user
  end
end