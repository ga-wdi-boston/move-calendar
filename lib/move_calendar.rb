require_relative "./ics_calendar.rb"

def move_calendar(input_file, output_file, interval_days)
  IcsCalendar.new(input_file, output_file, interval_days)
              .read_calendar
end
