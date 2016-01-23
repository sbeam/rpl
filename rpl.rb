# encoding: UTF-8
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

raw_entries = []

File.open('test/fixtures/rochester-times') do |f|
  the_log_url = scrape_landing_page f
  puts the_log_url
  File.open('test/fixtures/14326') do |the_log|
    the_log.each_line do |line|
      if line =~ /<blockquote/
         raw_entries += line.scan(/<blockquote\s*>(.*?)<\/blockquote\s*>\s*/)
      end
    end
  end
end

entries = EntryCollection.new(raw_entries)

entries.cleaned.each_with_index do |entry, i|
  if entry.date
    #time_to_send = (entry.date + entries.entry_time_offset).to_s                                    # schedule for now + n+1 days                 (Apr 20 9:48am)
    time_to_send = (Time.now + i*120 + 15).to_s
    puts "setting send for #{time_to_send}"
    entry.to_tweets.each do |tweet|
        puts tweet
        Resque.enqueue_at(Time.parse(time_to_send), SendTweet, tweet)
    end
  end
end
