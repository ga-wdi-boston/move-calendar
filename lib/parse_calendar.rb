# frozen_string_literal: true
require 'date'
# Reads and moves an ics calendar
class MoveCalendar
  attr_accessor :days_to_move, :ics_events
  attr_reader :input_file, :output_file

  def initialize(input_file, output_file, days_to_move)
    @input_file = input_file
    @output_file = output_file
    @days_to_move = days_to_move
    @ics_events = []
  end

  def parse_event(line, delimiter)
    d = line.split(/[\:\=](\d{8})/)
    d[1] = Date.parse(d[1])
    return line if d[1].year < 2016

    d[1] = (d[1] + days_to_move).to_s.delete('-')

    return d[0] + delimiter.to_s + d[1] + d[2] if d[2]

    d[0] + delimiter.to_s + d[1]
  end

  def read_calendar
    # open file in write-only mode
    write_to = File.open(output_file, 'w')
    File.open(input_file) do |file|
      # Loops through each line of file and labels it line
      file.each do |line|
        colon_delimited_lines = ['DTSTART:', 'DTSTART:', 'DTEND:', 'DTSTART;VALUE=',
                                 'DTEND;VALUE=', 'DTSTART;TZID=', 'DTEND;TZID=']
        if line.include?('RRULE:') && line.include?('UNTIL=')
          line = parse_event(line, '=')
        # if the line contains any of the strings in colon_delimited_lines,
        # parse it using a colon as the delimiter
        elsif colon_delimited_lines.any? { |string| line.include?(string) }
          line = parse_event(line, ':')
        end
        # Takes line value, either copied or altered, and writes to output file
        write_to.write(line)
        # Ends loop once it loops through whole input file
      end
      # Closes output file which new calendar was written to
      write_to.close
      # Closes input file to secure old data
    end
  end
end
