require 'rails_helper'
require 'spec_helper'
class OccurrencesControllerHelper
  def self.bypass_weather_factor_instances_worker
    WeatherFactorInstancesWorker.singleton_class.send(:alias_method, :old_perform_async, :perform_async)
    WeatherFactorInstancesWorker.singleton_class.send(:define_method, :perform_async) do |arg|
      nil
    end
  end

  def self.restore_weather_factor_instances_worker
    WeatherFactorInstancesWorker.singleton_class.send(:alias_method, :perform_async, :old_perform_async)
  end
end