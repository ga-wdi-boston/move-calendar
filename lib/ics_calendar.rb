# frozen_string_literal: true
require 'date'

require_relative './ics_event.rb'
# Reads and moves an ics calendar
class IcsCalendar
  attr_accessor :days_to_move, :ics_events, :in_event, :event_line_array
  attr_reader :input_file, :output_file
  # private :in_event, :event_line_array

  def initialize(input_file, output_file, days_to_move)
    @input_file = input_file
    @output_file = output_file
    @days_to_move = days_to_move
    @ics_events = []
    @in_event = false
    @event_line_array = []
  end

  def parse_event(line, delimiter)
    line_array = line.split(/[\:\=](\d{8})/)
    date = Date.parse(line_array[1])
    return line if date.year < 2016

    date = (date + days_to_move).to_s.delete('-')

    if line_array[2]
      return line_array[0] + delimiter.to_s + date + line_array[2]
    end

    line_array[0] + delimiter.to_s + date
  end

  def read_calendar
    # open file in write-only mode
    write_to = File.open(output_file, 'w')
    File.open(input_file) do |file|
      # Loops through each line of file and labels it line
      counter = 0
      file.each do |line|
        # puts 'in event', line if counter > 0 && counter < 5 && self.in_event == true
        self.in_event = true if line.include? 'BEGIN:VEVENT'

        if in_event == true
          event_line_array.push(line)
        end

        if line.include? 'END:VEVENT'
          self.in_event = false
          p event_line_array if counter == 0
          counter += 1
          event = IcsEvent.new(event_line_array)
          # puts event.start_date
          ics_events.push(IcsEvent.new(event_line_array))

          self.event_line_array = []
        end


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
