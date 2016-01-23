require_relative 'decoder'
require 'date'

class LogEntry

    attr_reader :lines

    def initialize entry, day
      @lines = [entry]
      @day = day
      @time = scan_time(entry)
    end

    def clean
      decode.collapse_times
    end

    def collapse_times
      if matches = @lines[0].match(/(\d+:\d+)\s*([ap])\.?m\.?[\s-]*/)
        @lines[0].gsub!(matches[0], "#{matches[1]}#{matches[2]}m ")
      end
      self
    end

    def decode
      @lines.map! { |line| Decoder.decode(line) }
      self
    end

    def date
      if @day && @time
        DateTime.parse("#{@day} #{@time}")
      end
    end

    def to_s
      "#{date.to_s}: #{@lines.join(' ')}"
    end

    def to_hash
      Digest::MD5.hexdigest(to_s)
    end

    def to_tweets
      if @lines[0].length > 140                   # tweetstorm!
          chunks = (@lines[0].length / 136)       # leave 4 chars for "page numbers"
          line = @lines[0]
          @lines = (0..chunks).map do |c|
            a = c*136
            z = ((c+1)*136) - 1
            #puts "#{c}: #{a} -> #{z}"
            "#{line[a..z]} #{(c+1).to_s}/#{(chunks+1).to_s}"
          end
      end
      @lines
    end

    def is_personal?
      # Christopher [M.] Thibeault, 25, of 74B Winter St.,
      to_s =~ /[A-Z]\w+ ([A-Z]\. )?[A-Z]\w+, \d+, (of|a|an) [^,]+,/
    end

    private

    def scan_time entry
      if matches = @lines[0].match(/(\d+:\d+)\s*([ap]\.?m\.?)/)
        "#{matches[1]} #{matches[2]}"
      end
    end
end
