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
    unless res.code == '201'
      err_msg = "Elasticsearch returns a code #{res.code} when adding this occurrence: #{occurrence.inspect}\n"
      err_msg += "ELASTIC_URL = #{ENV['ELASTIC_URL']}\n"
      err_msg += "JSON encoded occurrence = #{build_json(occurrence)}\n"
      raise(Exception, err_msg)
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
