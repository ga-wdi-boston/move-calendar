# frozen_string_literal: true
require 'date'
require 'holidays'

require_relative './ics_event.rb'
# Reads and moves an ics calendar
class IcsCalendar
  attr_accessor :days_to_move, :ics_events, :in_event, :event_line_array
  attr_reader :input_file, :output_file
  private :in_event, :event_line_array, :days_to_move

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

  def push_line(line)
    if in_event == true
      # if we're in an event, push the line to an array to store it
      @event_line_array.push(line)
    else
      # if not, push to the non-event array
      @non_event_lines.push(line)
    end
  end
  private :push_line

  def read_calendar(input_file)
    File.open(input_file) do |file|
      # Loops through each line of file and labels it line
      file.each do |line|
        self.in_event = true if line.include? 'BEGIN:VEVENT'

        push_line(line)

        # if the event is ending
        next unless line.include? 'END:VEVENT'
        self.in_event = false

        # create the ics_event
        @ics_events.push(IcsEvent.new(event_line_array))
        # reset the event_line_array
        self.event_line_array = []
      end
    end
  end
  private :read_calendar

  def add_ga_holidays(holidays)
    thanks_index = holidays.index { |holiday| holiday[:name] == 'Thanksgiving' }
    xmas_index = holidays.index { |holiday| holiday[:name] == 'Christmas Day' }

    if thanks_index
      holidays.push(name: 'Day after Thanksgiving',
                    date: holidays[thanks_index][:date] + 1)
    end

    if xmas_index
      holidays.push(name: 'Day after Christmas',
                    date: holidays[xmas_index][:date] + 1)
    end

    holidays
  end
  private :add_ga_holidays

  def get_candidate_dates(start_date, end_date)
    dates = [start_date]

    # get the US holidays for three months after when the
    # last event will be moved to
    base_holidays = Holidays.between(start_date, end_date, :us)
    holidays = add_ga_holidays(base_holidays)

    dates << dates.last + 1 while dates.last < end_date - 1

    dates.delete_if do |date|
      (date.sunday? || date.saturday? ||
        holidays.any? { |holiday| holiday[:date] == date })
    end
  end
  private :get_candidate_dates

  def move(days_to_move)
    sorted_events = ics_events.sort_by(&:start_date)

    first_moved_date = sorted_events.first.start_date + days_to_move
    # adds two weeks to the last date as a buffer
    last_moved_date = sorted_events.last.start_date + days_to_move + 14

    candidate_dates = get_candidate_dates(first_moved_date, last_moved_date)

    candidate_dates.each do |candidate_date|
      next unless sorted_events.length.positive?

      old_date = sorted_events.first.start_date

      events_to_move = select_events(sorted_events, old_date)

      # remove the events that we're going to move
      sorted_events
        .reject! { |sorted_event| sorted_event.start_date == old_date }

      # move the events to the candidate date
      move_event_array(events_to_move, candidate_date)
    end

    self
  end

  def select_events(events, date)
    events.select do |event|
      event.start_date == date
    end
  end
  private :select_events

  def move_event_array(event_array, date)
    event_array.each do |moving_event|
      days_to_move = (date - moving_event.start_date).to_i
      moving_event.move days_to_move
    end
  end
  private :move_event_array

  def write_calendar(output_file)
    # remove and save the last line of the calendar
    end_calendar = @non_event_lines.pop

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
