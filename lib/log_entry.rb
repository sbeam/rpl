require_relative 'decoder'
require 'date'

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
      if matches = @entry.match(/(\d+:\d+)\s*([ap])\.?m\.?[\s-]*/)
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
