# frozen_string_literal: true
require 'date'
require 'holidays'

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

  def get_candidate_dates(start_date, end_date)
    dates = [start_date]

    # get the US holidays for three months after when the
    # last event will be moved to
    holidays = Holidays.between(start_date, end_date, :us)

    dates << dates.last + 1 while dates.last < end_date - 1

    dates.delete_if do |date|
      (date.sunday? || date.saturday? ||
        holidays.any? { |holiday| holiday[:date] == date })
    end
  end

  def move(days_to_move)
    sorted_events = ics_events.sort_by(&:start_date)

    first_moved_date = sorted_events.first.start_date + days_to_move
    # adds two weeks to the last date as a buffer
    last_moved_date = sorted_events.last.start_date + days_to_move + 14

    candidate_dates = get_candidate_dates(first_moved_date, last_moved_date)

    old_events = ics_events.map(&:itself)

    candidate_dates.each do |candidate_date|
      next unless old_events.positive?
      old_date = old_events.first.start_date
      events_to_move = old_events
                       .select { |old_event| old_event.start_date == old_date }

      old_events.reject! { |old_event| old_event.start_date == old_date }

      events_to_move.each do |moving_event|
        days_to_move = (candidate_date - moving_event.start_date).to_i
        moving_event.move(days_to_move)
      end
    end

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
