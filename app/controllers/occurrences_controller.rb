class OccurrencesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    received_coordinate = params[:gps_coordinate]
    gps_coordinate = GpsCoordinate.new
    gps_coordinate = GpsCoordinate.new(
        accuracy: received_coordinate[:accuracy],
        altitude: received_coordinate[:altitude],
        altitude_accuracy: received_coordinate[:altitude_accuracy],
        heading: received_coordinate[:heading],
        speed: received_coordinate[:speed],
        latitude: received_coordinate[:latitude],
        longitude: received_coordinate[:longitude]
    ) unless not received_coordinate

    occurrence = Occurrence.new(symptom_id: params[:symptom_id],
                                date: params[:date],
    # factors: params[:factors]
    )
    if gps_coordinate.valid?
      occurrence.gps_coordinate = gps_coordinate
    end

    begin
      if occurrence.save
        render :nothing => true,
               :status => 200
      elsif not occurrence.valid?
        render :nothing => true,
               :status => 422
      else
        render :nothing => true,
               :status => 501
      end
    rescue ActiveRecord::InvalidForeignKey
      render :nothing => true,
             :status => 404
    end


  end
end
