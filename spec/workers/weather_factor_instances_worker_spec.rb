require 'rails_helper'
RSpec.describe WeatherFactorInstancesWorker, type: :worker do
    before(:each) do
      @instance = WeatherFactorInstancesWorker.new
    end
    describe '#get_closest_observation' do
        context 'when there are no observation' do
          it 'returns nil' do
            date = Time.now
            observations = []
            observation = @instance.get_closest_observation(date, observations)
            expect(observation).to eq nil
          end
        end
        context 'when there are observation' do
          it 'returns the observation with the closest date' do
            date = Time.parse('2012-07-11 21:00')
            closest_observation = { "date" => {"hour" => "20", "min" => "30"}, "tempm" => "26", "hum" => "60", "conds" => "overcast"}
            no_closest_observation = { "date" => {"hour" => "06", "min" => "30"}, "tempm" => "26", "hum" => "60", "conds" => "overcast"}
            observations = [closest_observation, no_closest_observation]
            observation = @instance.get_closest_observation(date, observations)
            expect(observation).to eq closest_observation
          end
        end
    end
    describe '#get_weather_information' do
      context 'when the latitude, longitude and the date are correct' do
          before(:each) do
              @closest_observation = { "date" => {"hour" => "20", "min" => "30"}, "tempm" => "26", "hum" => "60", "conds" => "overcast"}
              no_closest_observation = { "date" => {"hour" => "06", "min" => "30"}, "tempm" => "26", "hum" => "60", "conds" => "overcast"}
              expected_hash = {"response"=>{"version"=>"0.1", "termsofService"=>"http://www.wunderground.com/weather/api/d/terms.html", "features"=>{"history"=>1}}, "history"=>{"date"=>{"pretty"=>"March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"00", "tzname"=>"Europe/Brussels"}, "utcdate"=>{"pretty"=>"March 23, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"23", "hour"=>"23", "min"=>"00", "tzname"=>"UTC"}, "observations"=>[@closest_observation, no_closest_observation], "dailysummary"=>[{"date"=>{"pretty"=>"12:00 AM CET on March 24, 2017", "year"=>"2017", "mon"=>"03", "mday"=>"24", "hour"=>"00", "min"=>"00", "tzname"=>"Europe/Brussels"}, "fog"=>"0", "rain"=>"0", "snow"=>"0", "snowfallm"=>"", "snowfalli"=>"", "monthtodatesnowfallm"=>"", "monthtodatesnowfalli"=>"", "since1julsnowfallm"=>"", "since1julsnowfalli"=>"", "snowdepthm"=>"", "snowdepthi"=>"", "hail"=>"0", "thunder"=>"0", "tornado"=>"0", "meantempm"=>"6", "meantempi"=>"44", "meandewptm"=>"5", "meandewpti"=>"41", "meanpressurem"=>"1022.79", "meanpressurei"=>"30.20", "meanwindspdm"=>"14", "meanwindspdi"=>"9", "meanwdire"=>"ENE", "meanwdird"=>"57", "meanvism"=>"4.9", "meanvisi"=>"3.0", "humidity"=>"90", "maxtempm"=>"8", "maxtempi"=>"46", "mintempm"=>"5", "mintempi"=>"41", "maxhumidity"=>"100", "minhumidity"=>"70", "maxdewptm"=>"5", "maxdewpti"=>"41", "mindewptm"=>"4", "mindewpti"=>"39", "maxpressurem"=>"1026", "maxpressurei"=>"30.31", "minpressurem"=>"1021", "minpressurei"=>"30.14", "maxwspdm"=>"22", "maxwspdi"=>"14", "minwspdm"=>"11", "minwspdi"=>"7", "maxvism"=>"14.0", "maxvisi"=>"9.0", "minvism"=>"2.9", "minvisi"=>"1.8", "gdegreedays"=>"0", "heatingdegreedays"=>"22", "coolingdegreedays"=>"0", "precipm"=>"0.0", "precipi"=>"0.00", "precipsource"=>"3Or6HourObs", "heatingdegreedaysnormal"=>"", "monthtodateheatingdegreedays"=>"", "monthtodateheatingdegreedaysnormal"=>"", "since1sepheatingdegreedays"=>"", "since1sepheatingdegreedaysnormal"=>"", "since1julheatingdegreedays"=>"", "since1julheatingdegreedaysnormal"=>"", "coolingdegreedaysnormal"=>"", "monthtodatecoolingdegreedays"=>"", "monthtodatecoolingdegreedaysnormal"=>"", "since1sepcoolingdegreedays"=>"", "since1sepcoolingdegreedaysnormal"=>"", "since1jancoolingdegreedays"=>"", "since1jancoolingdegreedaysnormal"=>""}]}}
              allow(WeatherFactorInstancesWorker.class_variable_get '@@w_api').to receive(:history_for) { expected_hash}
          end

          it 'returns the observation with the closest date' do
              date = Time.parse('2012-07-11 21:00')
              result = WeatherFactorInstancesWorker.new.get_weather_information(nil, nil, date)
              expect(result).to be_instance_of Hash
              expect(result).to eq @closest_observation
          end

      end
    end
end
