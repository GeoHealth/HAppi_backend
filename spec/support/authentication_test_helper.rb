class AuthenticationTestHelper

  # Create a new valid User and save it in database.
  # Set the headers of the given *request* object.
  # Returns the created user
  def self.set_valid_authentication_headers(request)
    user = FactoryGirl.create(:user)
    @auth_headers = user.create_new_auth_token
    request.headers.merge!(@auth_headers)
    return user
  end
end