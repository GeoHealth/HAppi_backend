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

  def get_weather_information(latitude, longitude, date)
    year_month_day = date.strftime("%Y%m%d")

    response =@@w_api.history_for(year_month_day, "#{latitude},#{longitude}")
    observations = response['history']['observations']

    result_observation = nil
    hour_day = date.strftime("%H%M")
    min = 9999

    observations.each do |observation|
      observation_date = observation['date']['hour'] + observation['date']['min']
      dif = (observation_date.to_i - hour_day.to_i).abs
      if dif < min then
        min = dif
        result_observation = observation
      end
    end
    result_observation
  end
end
