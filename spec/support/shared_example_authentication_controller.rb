RSpec.shared_examples 'GET protected with authentication controller' do |action|
  context 'without valid authentication headers' do
    before(:each) do
      get action
    end

    it 'responds with 401' do
      is_expected.to respond_with 401
    end
  end
end

RSpec.shared_examples 'POST protected with authentication controller' do |action, parameters|
  context 'without valid authentication headers' do
    before(:each) do
      post action, parameters
    end

    it 'responds with 401' do
      is_expected.to respond_with 401
    end
  end
end

RSpec.shared_examples 'DELETE protected with authentication controller' do |action, parameters|
  context 'without valid authentication headers' do
    before(:each) do
      delete action, parameters
    end

    it 'responds with 401' do
      is_expected.to respond_with 401
    end
  end
end