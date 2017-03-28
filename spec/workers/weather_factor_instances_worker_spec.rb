require 'rails_helper'
RSpec.describe WeatherFactorInstancesWorker, type: :worker do
  describe '#get_weather_information' do
    it '' do
      expected_hash = {"date" => {"pretty" => "12:00 AM CET on March 24, 2017", "year" => "2017", "mon" => "03", "mday" => "24", "hour" => "00", "min" => "00", "tzname" => "Europe/Brussels"}, "utcdate" => {"pretty" => "11:00 PM GMT on March 23, 2017", "year" => "2017", "mon" => "03", "mday" => "23", "hour" => "23", "min" => "00", "tzname" => "UTC"}, "tempm" => "8", "tempi" => "46", "dewptm" => "4", "dewpti" => "39", "hum" => "70", "wspdm" => "14.4", "wspdi" => "8.9", "wgustm" => "", "wgusti" => "", "wdird" => "50", "wdire" => "NE", "vism" => "14", "visi" => "9", "pressurem" => "1021", "pressurei" => "30.14", "windchillm" => "-999", "windchilli" => "-999", "heatindexm" => "-9999", "heatindexi" => "-9999", "precipm" => "", "precipi" => "", "conds" => "Overcast", "icon" => "cloudy", "fog" => "0", "rain" => "0", "snow" => "0", "hail" => "0", "thunder" => "0", "tornado" => "0", "metar" => "AAXX 23231 06458 45964 /0504 10080 20041 30070 40207 51027 333 88/62 91108 91206"}
      allow(WeatherFactorInstancesWorker.class_variable_get '@@w_api').to receive(:history_for) { {"history" => {"observations" => [expected_hash]}} }
      result = WeatherFactorInstancesWorker.new.get_weather_information(nil, nil, Time.now)
      expect(result).to be_instance_of Hash
      expect(result).to eql expected_hash
    end
  end
end
