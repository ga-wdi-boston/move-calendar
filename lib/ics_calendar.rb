# frozen_string_literal: true
require 'date'

require_relative './ics_event.rb'
# Reads and moves an ics calendar
class IcsCalendar
  attr_accessor :days_to_move, :ics_events, :in_event, :event_line_array
  attr_reader :input_file, :output_file
  # private :in_event, :event_line_array

  def initialize(input_file)
    @input_file = input_file
    @output_file = output_file
    @non_event_lines = []
    @ics_events = []
    @in_event = false
    @event_line_array = []
    @holidays = []
    read_calendar(input_file)
  end

  def read_calendar(input_file)
    File.open(input_file) do |file|
      # Loops through each line of file and labels it line
      file.each do |line|
        self.in_event = true if line.include? 'BEGIN:VEVENT'

        if self.in_event == true
          # if we're in an event, push the line to an array to store it
          @event_line_array.push(line)
        else
          # if not, push to the non-event array
          @non_event_lines.push(line)
        end

        # if the event is ending
        if line.include? 'END:VEVENT'
          self.in_event = false

          # create the ics_event
          @ics_events.push(IcsEvent.new(event_line_array))
          # reset the event_line_array
          self.event_line_array = []
        end
      end
    end
  end

  def move(days_to_move)
    sorted_events = ics_events.sort_by(&:start_date)
    # puts sorted_events.first
    self.ics_events = sorted_events.each do |event|
      event.move(days_to_move)
      if event.start_date.sunday?
        event.move(1)
      elsif event.start_date.saturday?
        event.move(2)
      end
    end

    $stdout.write ics_events.first.start_date
    self
  end

  def write_calendar(output_file)
    end_calendar = @non_event_lines.pop()

    # open file in write-only mode
    write_file = File.open(output_file, 'w')
    @non_event_lines.each do |line|
      write_file.write line
    end

    @ics_events.each do |event|
      event.to_ics.each do |line|
        write_file.write line
      end
    end

    write_file.write(end_calendar)
    write_file.close
  end
end
