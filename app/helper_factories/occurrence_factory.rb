class OccurrenceFactory
  def self.build_from_params(json_occurrence)
    json_occurrence = JSON.parse(json_occurrence) if json_occurrence.class == String

    occurrence = Occurrence.new
    if json_occurrence
      occurrence = Occurrence.new symptom_id: json_occurrence['symptom_id'],
                                  date: json_occurrence['date']
      occurrence.gps_coordinate = GpsCoordinateFactory.build_from_params(json_occurrence['gps_coordinate']) if json_occurrence['gps_coordinate']
    end
    return occurrence
  end
end