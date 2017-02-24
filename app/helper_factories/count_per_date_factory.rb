class CountPerDateFactory
  # Group occurrences per unit and return an array of CountPerDate.
  # The number of elements in the array is equal to the number of units between start_date and end_date
  # @param [Array<Occurrence>] occurrences
  # @param [string] unit: [hours, days, months, years]
  # @return [Array<CountPerDate>]
  def self.group_by(occurrences, start_date, end_date, unit)
    counts_per_date = generate_array_for_unit(start_date, end_date, unit)
    occurrences.each do |occurrence|
      index = compute_number_of_units_between(start_date, occurrence.date, unit)
      counts_per_date.fetch(index).count += 1
    end
    counts_per_date
  end

  # Generate and return an array of CountPerDate containing x elements, separated by 1 unit
  # where x is the number of units between start_date and end_date.
  # @param [ActiveSupport::TimeWithZone] start_date starting date
  # @param [ActiveSupport::TimeWithZone] end_date ending date
  # @param [string] unit [hours, days, months, years]
  # @return [Array<CountPerDate]
  def self.generate_array_for_unit(start_date, end_date, unit)
    number_of_elements = compute_number_of_units_between(start_date, end_date, unit) + 1
    counts_per_date = Array.new(number_of_elements) { CountPerDate.new }
    counts_per_date.each_with_index do |count_per_date, index|
      count_per_date.date = start_date + index.send(unit)
    end
    counts_per_date
  end

  # Compute the number of unit between the start_date and the end_date
  # The returned value is always positive
  # @param [ActiveSupport::TimeWithZone] start_date
  # @param [ActiveSupport::TimeWithZone] end_date
  # @param [string] unit [hours, days, months, years]
  # @return [integer]
  def self.compute_number_of_units_between(start_date, end_date, unit)
    case unit
      when 'hours'
        (end_date - start_date).to_i.abs / 3600
      when 'days'
        (end_date.to_date - start_date.to_date).to_i.abs
      when 'months'
        ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)).to_i.abs
      when 'years'
        (end_date.year - start_date.year).to_i.abs
      else
        raise ArgumentError.new('unit must be one of [hours, days, months, years]')
    end
  end
end