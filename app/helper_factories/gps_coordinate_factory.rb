class GpsCoordinateFactory
  def self.build_from_params(json_gpscoordinate)
    json_gpscoordinate = JSON.parse(json_gpscoordinate) if json_gpscoordinate.class.equal?(String)

    gps_coordinate = GpsCoordinate.new
    if json_gpscoordinate
      gps_coordinate = GpsCoordinate.new(
          accuracy: json_gpscoordinate['accuracy'],
          altitude: json_gpscoordinate['altitude'],
          altitude_accuracy: json_gpscoordinate['altitude_accuracy'],
          heading: json_gpscoordinate['heading'],
          speed: json_gpscoordinate['speed'],
          latitude: json_gpscoordinate['latitude'],
          longitude: json_gpscoordinate['longitude']
      )
    end

    gps_coordinate
  end
end