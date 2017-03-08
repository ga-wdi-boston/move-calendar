# frozen_string_literal: true
require_relative '../move_calendar.rb'

desc 'Move an ics calendar forward'
task :move_calendar, [:input_file,
                      :output_file,
                      :start_date] do |_task, args|
  puts 'Moving calendar'

  unless args[:start_date]
    raise 'Usage: bin/rake "move_calendar[<input_file>, <output_file>,' \
          ' <start_date>]" \n start_date must have the format YYYY-MM-DD'
  end

  move_calendar(args[:input_file], args[:output_file], args[:start_date])
end
