class OccurrencesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    begin
      post_body = JSON.parse(request.raw_post)
    rescue JSON::ParserError
      render :nothing => true,
             :status => 422
      return
    end

    received_coordinate = post_body['gps_coordinate']
    gps_coordinate = GpsCoordinate.new
    if received_coordinate
      gps_coordinate = GpsCoordinate.new(
          accuracy: received_coordinate['accuracy'],
          altitude: received_coordinate['altitude'],
          altitude_accuracy: received_coordinate['altitude_accuracy'],
          heading: received_coordinate['heading'],
          speed: received_coordinate['speed'],
          latitude: received_coordinate['latitude'],
          longitude: received_coordinate['longitude']
      )
    end

    occurrence = Occurrence.new(symptom_id: post_body['symptom_id'],
                                date: post_body['date'],
    # factors: post_body[:factors]
    )
    if gps_coordinate.valid?
      occurrence.gps_coordinate = gps_coordinate
    end

    begin
      if occurrence.save
        render :nothing => true,
               :status => 200
        return
      elsif not occurrence.valid?
        render :nothing => true,
               :status => 422
        return
      else
        render :nothing => true,
               :status => 501
        return
      end
    rescue ActiveRecord::InvalidForeignKey
      render :nothing => true,
             :status => 404
      return
    end
  end
end
