# frozen_string_literal: true

require_relative './ics_calendar.rb'

def move_calendar(input_file, output_file, interval_days)
  calendar = IcsCalendar.new(input_file)

  calendar.move(interval_days).write_calendar(output_file)
end
