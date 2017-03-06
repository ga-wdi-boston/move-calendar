# frozen_string_literal: true

# Class representing an ics event as an array of strings
class IcsEvent
  attr_accessor :ics_event, :start_date, :end_date

  def initialize(lines_array)
    @ics_event = lines_array
    lines_array.each do |line|
      @start_date = parse_event(line) if line.include? 'DTSTART'
      @end_date = parse_event(line) if line.include? 'DTEND'
    end
  end

  def parse_event(line)
    line_array = line.split(/[\:\=](\d{8})/)
    Date.parse(line_array[1])
  end

  def move_event(days)

  end
end
