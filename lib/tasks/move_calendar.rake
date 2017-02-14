# frozen_string_literal: true
require_relative '../parse_calendar.rb'

desc 'Move an ics calendar forward'
task :move_calendar, [:input_file,
                      :output_file,
                      :interval_weeks] do |_task, args|
  puts 'Moving calendar'

  unless args[:interval_weeks]
    raise 'Usage: bin/rake "move_calendar[<input_file>, <output_file>,' \
          ' <interval_weeks>]"'
  end

  # Convert weeks to days
  interval_days = args[:interval_weeks].to_i * 7
  MoveCalendar.new(args[:input_file], args[:output_file], interval_days).read_calendar
end
