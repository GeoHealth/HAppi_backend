class AveragePerPeriod
  attr_accessor :symptoms, :unit

  def initialize(attributes = {})
    self.symptoms = attributes[:symptoms]
    self.unit = attributes[:unit]
  end

  def symptoms=(value)
    if value.nil? or (value.instance_of? Array and value.all? { |x| x.is_a? SymptomWithAverage })
      @symptoms = value
    else
      raise ArgumentError.new('must be an Array of SymptomWithAverage')
    end
  end

  def unit=(value)
    valid_units = %w(hour day_of_week month year)
    if value.nil? or valid_units.include? value
      @unit = value
    else
      raise ArgumentError.new("#{value} is not included in #{valid_units}")
    end
  end
end