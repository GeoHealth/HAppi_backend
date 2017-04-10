class ElasticsearchWorker
  include Sidekiq::Worker

  def perform(occurrence_id)
    occurrence = Occurrence.find(occurrence_id)
    if (occurrence)
      uri = URI("http://localhost:9200/occurrences/#{occurrence.id}")
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = occurrence.to_json
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end
    res
  end
end
