class ElasticsearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 2

  def perform(occurrence_id)
    occurrence = Occurrence.find(occurrence_id)
    if (occurrence)
      raise(Exception, 'No ELASTIC_URL found') if not ENV['ELASTIC_URL']
      uri = URI(ENV['ELASTIC_URL'] + (occurrence.id).to_s)
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = build_json(occurrence)
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end
    res
  end

  def build_json(occurrence)
    result = JSON::parse(occurrence.to_json).merge('location' => "#{occurrence.gps_coordinate.latitude}, #{occurrence.gps_coordinate.longitude}")
    result.to_json
  end

end
