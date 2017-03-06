require_relative "./ics_calendar.rb"

def move_calendar(input_file, output_file, interval_days)
  calendar = IcsCalendar.new(input_file)
  puts calendar.ics_events.first.start_date
  calendar.move(2)
  puts calendar.ics_events.first.start_date
  calendar.write_calendar(output_file)
end
