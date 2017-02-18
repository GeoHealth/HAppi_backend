class SymptomWithAverage
  attr_accessor :id, :name, :averages

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @averages = attributes[:averages]
  end

  def averages=(value)
    if value.nil? or (value.instance_of? Array and value.all? { |x| x.is_a? Integer })
      @averages = value
    else
      raise ArgumentError.new('must be an Array of Integer')
    end
  end
end