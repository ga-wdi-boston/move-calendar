# frozen_string_literal: true

# Class representing an ics event as an array of strings
class IcsEvent
  attr_reader :ics_event, :summary
  attr_accessor :start_date, :end_date

  def initialize(lines_array)
    @ics_event = lines_array
    lines_array.each do |line|
      @start_date = parse_date(line) if line.include? 'DTSTART'
      @end_date = parse_date(line) if line.include? 'DTEND'
      @summary = parse_description(line) if line.include? 'SUMMARY'
    end
  end

  def parse_description(line)
    line_array = line.split(':')
    line_array[1].chomp
  end
  private :parse_description

  def parse_date(line)
    line_array = line.split(/[\:\=](\d{8})/)
    Date.parse(line_array[1])
  end
  private :parse_date

  def write_date_line(line, date)
    line_array = line.split(/[\:\=](\d{8})/)
    if line_array[2]
      return line_array[0] + ':' + date.strftime('%Y%m%d') + line_array[2]
    end

    line_array[0] + ':' + date.strftime('%Y%m%dT%H%M%S')
  end

  def to_ics
    ics_event.map do |line|
      if line.include? 'DTSTART'
        write_date_line(line, start_date)
      elsif line.include? 'DTEND'
        write_date_line(line, end_date)
      else
        line
      end
    end
  end

  def move(days)
    self.start_date += days
    self.end_date += days
    self
  end
end
