class ElasticsearchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 2

  def perform(occurrence_id)
    occurrence = Occurrence.find(occurrence_id)
    if (occurrence)
      raise(Exception, 'No ELASTIC_URL found') if not ENV['ELASTIC_URL']
      uri = URI(ENV['ELASTIC_URL'] + '/occurrences/' + (occurrence.id).to_s)
      req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
      req.body = build_json(occurrence)
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
    end
    res
  end

  def build_json(occurrence)
    result = {'occurrence_id' => occurrence.id,
            'symptom_id' => occurrence.symptom_id,
            'user_id' => occurrence.user_id,
            'date' => occurrence.date,
            'symptom_name' => occurrence.symptom.name
          }
    if (occurrence.gps_coordinate)
      result = JSON::parse(result.to_json).merge('location' => "#{occurrence.gps_coordinate.latitude}, #{occurrence.gps_coordinate.longitude}")
    end
    result.to_json
  end
end
