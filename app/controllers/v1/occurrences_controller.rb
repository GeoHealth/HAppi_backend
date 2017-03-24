class  V1::OccurrencesController < V1::BaseController
  include DeviseTokenAuth::Concerns::SetUserByToken
  before_action :authenticate_user!

  @@w_api = Wunderground.new("1070f206b3f8b543")


  def create
    @occurrence = OccurrenceFactory.build_from_params(params[:occurrence])
    @occurrence.user = current_user


    unless @occurrence.gps_coordinate.nil? then
      latitude = @occurrence.gps_coordinate.latitude.to_s
      longitude = @occurrence.gps_coordinate.longitude.to_s


      observation = get_weather_information(latitude, longitude, @occurrence.date)


      @occurrence.factor_instances << [FactorInstance.new(factor_id:1,value:observation['tempm'])]
      @occurrence.factor_instances << [FactorInstance.new(factor_id:2,value:observation['hum'])]
      @occurrence.factor_instances << [FactorInstance.new(factor_id:3,value:observation['conds'])]


    end


    begin
      if @occurrence.save
        render json: @occurrence, status: 201
      else
        render :nothing => true, status: 422
      end
    rescue ActiveRecord::InvalidForeignKey
      render :nothing => true, status: 422
    end
  end

  def index
    @occurrences = Occurrence.where(user: current_user)
    render json: {occurrences: @occurrences}
  end

  def destroy
    begin
      occurrence = Occurrence.find_by(id: params.fetch(:occurrence_id))
      occurrence.destroy
      render json: occurrence
    rescue ActionController::ParameterMissing
      render :nothing => true, status: 422
    end
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

  def self.w_api=(value)
    @@w_api = value
  end
end