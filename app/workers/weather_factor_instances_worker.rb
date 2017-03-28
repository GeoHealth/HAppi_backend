class WeatherFactorInstancesWorker
  include Sidekiq::Worker

  @@w_api = Wunderground.new


  def perform(occurrence_id)
    # Do something

    occurrence = Occurrence.find(occurrence_id)

    latitude = occurrence.gps_coordinate.latitude.to_s
    longitude = occurrence.gps_coordinate.longitude.to_s

    observation = get_weather_information(latitude, longitude, occurrence.date)

    occurrence.factor_instances << [FactorInstance.new(factor_id:1,value:observation['tempm'])]
    occurrence.factor_instances << [FactorInstance.new(factor_id:2,value:observation['hum'])]
    occurrence.factor_instances << [FactorInstance.new(factor_id:3,value:observation['conds'])]

    occurrence.save
  end

  #Returns the closest weather observation of date
  def get_weather_information(latitude, longitude, date)
    #Transform the date into a format Year Month Date
    observations_date = date.strftime("%Y%m%d")

    #Call the Wunderground service to get the observations for the place define
    #by longitude and latitude for the date (= observations_date)
    response =@@w_api.history_for(observations_date, "#{latitude},#{longitude}")
    observations = response['history']['observations']

    get_closest_observation(date, observations)
  end

  #Returns the closest observation from observations according the time
  def get_closest_observation(date, observations)
    closest_observation = nil
    #Get the Hour and the minutes from date
    #Tips: to compute the difference between two dates, we concatenate the hour and the minutes for
    # each date and we compute the difference between them
    hour_day = date.strftime("%H%M")
    #Min is set to the max value of the difference between the date (of the closest observation)
    # and the date (of the observations)
    min = 9999

    observations.each do |observation|
      observation_date = observation['date']['hour'] + observation['date']['min']
      dif = (observation_date.to_i - hour_day.to_i).abs
      if dif < min then
        min = dif
        closest_observation = observation
      end
    end
    closest_observation
  end
end
