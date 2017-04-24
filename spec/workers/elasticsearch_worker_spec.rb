require 'rails_helper'
RSpec.describe ElasticsearchWorker, type: :worker do

  before(:each) do
    @e = ElasticsearchWorker.new
  end

  describe '#perform' do

    context 'when there is an ELASTIC_URL' do
      before(:each) do
        @elastic_url = 'http://username:password@test:9200'
        @elastic_url_clean = 'http://test:9200'
        ENV['ELASTIC_URL'] = @elastic_url
      end

      context 'when there are no occurrence in db' do
        it 'raise an exception ActiveRecord::RecordNotFound' do
          assert_raises(ActiveRecord::RecordNotFound) do
            @e.perform(1)
          end
        end
      end

      context 'when there is an occurrence with gps coordinates in db' do
        before(:each) do
          @occurrence = create(:occurrence_with_gps_coordinates)
        end

        context 'when http post is done' do
          before(:each) do
            @url = @elastic_url_clean + '/occurrences/' + @occurrence.id.to_s
            stub_request(:post, @url).to_return(status: 201)
          end

          it 'returns code 201' do
            expect(@e.perform(@occurrence.id).code).to eq ('201')
          end
        end

        context 'when http post returns 500' do
          before(:each) do
            @url = @elastic_url_clean + '/occurrences/' + @occurrence.id.to_s
            stub_request(:post, @url).to_return(status: 500)
          end

          it 'raises an exception' do
            expect{@e.perform(@occurrence.id)}.to raise_exception Exception
          end
        end
      end

      context 'when there is an occurrence without gps coordinates in db' do
        before(:each) do
          @occurrence = create(:occurrence)
        end

        it 'raise an Exception' do
          assert_raises(Exception) do
            @e.perform(@occurrence.id)
          end
        end
      end
    end

    context 'when there is no ELASTIC_URL' do
      before(:each) do
        ENV['ELASTIC_URL'] = nil
      end

      it 'raise an exception ' do
        assert_raises(Exception) do
          @e.perform(1)
        end
      end
    end
  end
end
