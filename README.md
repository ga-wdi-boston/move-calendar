# move-calendar

## Purpose
The purpose of this calendar script is to take an exisiting Google calendar or
iCalendar (as an `.ics` file) and create a new calendar from it.

## Problem
There was an exisiting Google calendar that had over 200 events associated with
it. In order to duplicate the old .ics calendar, you had to copy each individual
 event to a new date. A second problem was the trivial, and time consuming,
 process of manually moving each copied calendar event to it's new date.

## Solution
Created a Ruby script which takes an exisiting .ics file and copies it to a new
.ics calendar file. You can either copy the entire calendar to have it's events
appear on the same day or add *n* number of days to the calendar. This will move
the new events dates up by *n* days while keeping all information
(time, summary, description, etc.) the same as the old .ics file.

## Usage
Once you have the script.rb file cloned, choose which input calendar file you'd
like to copy and create a file for the new .ics calendar file.

To run the script, execute this command in terminal:

```sh
bin/rake "move_calendar[<input_file>, <output_file>, <new_start_date>]"
```
The quotes around the rake task are necessary. Quotes are not necessary around
file names.

This script takes the old .ics calendar file, and writes a new .ics calendar
file and new start date of the calendar. The start date should be in the format
`'YYYY-MM-DD'`.

## [License](LICENSE)

1.  All content is licensed under a CC­BY­NC­SA 4.0 license.
1.  All software code is licensed under GNU GPLv3. For commercial use or
    alternative licensing, please contact legal@ga.co.
