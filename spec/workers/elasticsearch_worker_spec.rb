require 'rails_helper'
RSpec.describe ElasticsearchWorker, type: :worker do

  describe '#perform' do
    before(:each) do
      @e = ElasticsearchWorker.new
    end
    context 'when there are no occurrence in db' do
      it 'raise an exception ActiveRecord::RecordNotFound' do
        assert_raises(ActiveRecord::RecordNotFound) do
          @e.perform(1)
        end
      end
    end
    context 'when there are occurrence in db' do
      before(:each) do
        @occurrence = create(:occurrence_with_gps_coordinates)
      end
      context 'when http post is done' do
        before(:each) do
          @url = ENV['ELASTIC_URL'] + @occurrence.id.to_s
          stub_request(:any, @url).to_return(status: 202)
        end
        it 'returns code 202' do
          expect(@e.perform(@occurrence.id).code).to eq ("202")
        end
      end
    end
  end
end
