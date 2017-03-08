# frozen_string_literal: true

require_relative './ics_calendar.rb'

def move_calendar(input_file, output_file, start_date)
  calendar = IcsCalendar.new(input_file)
  parsed_date = Date.parse(start_date)

  calendar.move_to(parsed_date).write_calendar(output_file)
end
