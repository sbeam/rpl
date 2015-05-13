# encoding: UTF-8
require 'htmlentities'
require 'date'
require 'resque'
require 'resque-scheduler'
require 'digest'
require './send_tweet'

Resque::Scheduler.configure do |c|
  c.quiet = false
  c.verbose = true
  c.logfile = nil # meaning all messages go to $stdout
  c.logformat = 'text'
end

landingpage = 'http://www.fosters.com/rochester-times'

class Decoder
  class << self
    def decode str
      utfcoder.decode(str)
    end
    def utfcoder
      @coder ||= HTMLEntities.new
    end
  end
end


class LogEntry

    attr_reader :entry
    def initialize entry, day
      @entry = entry
      @day = day
      @time = scan_time(entry)
    end

    def clean
      decode.collapse_times
    end

    def collapse_times
      if matches = @entry.match(/(\d+:\d+)\s*([ap])\.?m\.?[\s–]*/)
        @entry.gsub!(matches[0], "#{matches[1]}#{matches[2]}m ")
      end
      self
    end

    def decode
      @entry = Decoder.decode(@entry)
      self
    end

    def date
      if @day && @time
        DateTime.parse("#{@day} #{@time}")
      end
    end

    def to_s
      "#{date.to_s}: #{@entry}"
    end

    def to_hash
      Digest::MD5.hexdigest(to_s)
    end

    def to_tweet
      @entry
    end

    def is_personal?
      # Christopher [M.] Thibeault, 25, of 74B Winter St.,
      @entry =~ /[A-Z]\w+ ([A-Z]\. )?[A-Z]\w+, \d+, of [^,]+/
    end

    private

    def scan_time entry
      if matches = @entry.match(/(\d+:\d+)\s*([ap]\.?m\.?)/)
        "#{matches[1]} #{matches[2]}"
      end
    end
end

class EntryCollection
    #include Enumerable
    def initialize lines
      day = nil
      @entries = []

      lines.each do |line|
        e = line.pop
        if e != ""
          if matches = e.match(/<strong>(.*?)<\/strong>/)
            day = matches[1]
          else
            @entries << LogEntry.new(e, day)
          end
        end
      end
    end

    def cleaned
      @entries.reject(&:is_personal?).map(&:clean)
    end

end


#@doc = Nokogiri::XML(File.open("rochester-times"))

coder = HTMLEntities.new

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

first_day = entries.detect { |e| !e.date.nil? }.date
that_midnight = DateTime.new(first_day.year, first_day.month, first_day.day)
puts that_midnight.to_s

now = DateTime.now
midnight = DateTime.new(now.year, now.month, now.day)
puts midnight.to_s
offset = midnight - that_midnight
puts offset.to_s

entries.each do |entry|
  if entry.date
    time_to_send = (entry.date + offset).to_s
    puts "setting send for #{time_to_send}"
    Resque.enqueue_at(Time.parse(time_to_send), SendTweet, entry.entry)
  end
end
