# encoding: UTF-8
require 'htmlentities'
require 'date'
require 'resque'
require 'resque-scheduler'
require 'digest'

Dir["#{File.dirname __FILE__}/lib/*.rb"].each { |file| require file }

require './send_tweet'


Resque::Scheduler.configure do |c|
  c.quiet = false
  c.verbose = true
  c.logfile = nil # meaning all messages go to $stdout
  c.logformat = 'text'
end

landingpage = 'http://www.fosters.com/rochester-times'

def scrape_landing_page file
        file.each_line do |line|
            if line =~ /Rochester Police Log/
               puts line
               if matches = line.match(/href="([^"]+)"/)
                  return matches[1]
               end
            end
        end
end

collection = nil

File.open('rochester-times') do |f|
  the_log_url = scrape_landing_page f
  puts the_log_url
  # TODO fetch it
  File.open('14326') do |the_log|
    the_log.each_line do |line|
      if line =~ /<blockquote/
         collection = EntryCollection.new line.scan /<blockquote\s*>(.*?)<\/blockquote\s*>\s*/
      end
    end
  end
end

entries = collection.cleaned

first_day = entries.detect { |e| !e.date.nil? }.date                             # get the day of the first entry              (Apr 12 9:48am)
that_midnight = DateTime.new(first_day.year, first_day.month, first_day.day)     # go to the following midnight                (Apr 13 00:00)
puts that_midnight.to_s

now = DateTime.now                                                               # today, obviously                            (Apr 19, 5:50pm)
midnight = DateTime.new(now.year, now.month, now.day)                            # get todays midnight                         (Apr 20 00:00)
puts midnight.to_s
offset = midnight - that_midnight + 1                                            # offset is now - days since first entry +1   (8)
puts offset.to_s

entries.each do |entry|
  if entry.date
    time_to_send = (entry.date + offset).to_s                                    # schedule for now + n+1 days                 (Apr 20 9:48am)
    puts "setting send for #{time_to_send}"
    Resque.enqueue_at(Time.parse(time_to_send), SendTweet, entry.entry)
  end
end
