class OccurrenceFactory
  def self.build_from_params(json_occurrence)
    json_occurrence = JSON.parse(json_occurrence) if json_occurrence.class.equal?(String)

    occurrence = Occurrence.new
    if json_occurrence
      occurrence = Occurrence.new symptom_id: json_occurrence.fetch('symptom_id', nil),
                                  date: json_occurrence.fetch('date', nil)
      occurrence.gps_coordinate = GpsCoordinateFactory.build_from_params(json_occurrence.fetch('gps_coordinate')) if json_occurrence.key?('gps_coordinate')
    end

    occurrence
  end
end