require_relative 'decoder'
require 'date'

class LogEntry
    RPL_TIME_REGEX = /(\d+:\d+)\s*([ap]\.?m\.?)\s*/

    def initialize entry, day
      @day = day
      @time = scan_time(entry)

      @entry = Decoder.decode(re_timestamp(entry))
    end

    def date
      if @day && @time
        date = DateTime.parse("#{@day} #{@time}")
        if date > DateTime.now                  # if the date seems to be in future, must have been Auld Lang Syne
          DateTime.new(date.year - 1, date.month, date.day, date.hour, date.minute)
        else
          date
        end
      end
    end

    def date_fmt
      if d = date
        date.strftime("%b %-d %l:%M%P").gsub(/\s+/, ' ')
      end
    end

    def to_hash
      Digest::MD5.hexdigest(@entry)
    end

    def to_tweets
      if @entry.length > 140                        # tweetstorm!
          chunks = (@entry.length / 136)            # leave 4 chars for "page numbers"
          (0..chunks).map do |c|
            a = c*136
            z = ((c+1)*136) - 1
            #puts "#{c}: #{a} -> #{z}"
            "#{@entry[a..z]} #{(c+1).to_s}/#{(chunks+1).to_s}"
          end
      else
        [@entry]
      end
    end

    def is_personal?
      # Christopher [M.] Thibeault, 25, of 74B Winter St.,
      @entry =~ /[A-Z]\w+ ([A-Z]\. )?[A-Z]\w+, \d+, (of|a|an) [^,]+,/
    end

    def sendable?
      !is_personal? && @day && @time
    end

    private

    def scan_time entry
      if matches = entry.match(RPL_TIME_REGEX)
        "#{matches[1]} #{matches[2]}"
      end
    end

    def re_timestamp entry
      entry.gsub(RPL_TIME_REGEX, "#{date_fmt} ")
    end
end
