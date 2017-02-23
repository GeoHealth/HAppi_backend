class CountPerDateFactory
  # Group occurrences per hour and return an array of CountPerDate
  # @param [Array<Occurrence>] occurrences
  # @return [Array<CountPerDate>]
  def self.per_hour(occurrences)
    occurrences = occurrences.sort { |a, b| a.date <=> b.date }
    first_occurrence = occurrences.first
    last_occurrence = occurrences.last
    counts_per_date = generate_array_per_hours(first_occurrence.date, last_occurrence.date)
    occurrences.each do |occurrence|
      index = compute_hours_between(first_occurrence.date, occurrence.date)
      counts_per_date.fetch(index).count += 1
    end
    counts_per_date
  end

  # Generate and return an array of CountPerDate containing one instance per hour between first and last date
  def self.generate_array_per_hours(first, last)
    number_of_hours = compute_hours_between(first, last) + 1
    generate_array_for_unit(first, number_of_hours, :hours)
  end

  # Generate and return an array of CountPerDate containing number_of_elements elements, separated by 1 unit
  # @param [ActiveSupport::TimeWithZone] first starting date
  # @param [integer] number_of_elements to create in the array
  # @param [symbol] unit either [:hours, :days, :months, :years]
  def self.generate_array_for_unit(first, number_of_elements, unit)
    counts_per_date = Array.new(number_of_elements) { CountPerDate.new }
    counts_per_date.each_with_index do |count_per_date, index|
      count_per_date.date = first + index.send(unit)
    end
    counts_per_date
  end

  # Compute the number of hours between the first and the last DateTime
  # The returned value is always positive
  def self.compute_hours_between(first, last)
    seconds_in_an_hour = 3600
    ((last - first) / seconds_in_an_hour).to_i.abs
  end
end