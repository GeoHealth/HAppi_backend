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
end
