require_relative 'log_entry'
require 'date'
require 'tzinfo'

class EntryCollection

    def initialize lines
      @entries = []
      day = nil
      lines.each do |line|
        line = line.shift
        if line != ""
          if matches = line.match(/<strong>(.*?)<\/strong>/)
            day = matches[1]
          else
            @entries << LogEntry.new(line, day)
          end
        end
      end

      @tz = TZInfo::Timezone.get('America/New_York')
    end

    def each &b
      to_a.each do |entry|
        time_to_send = @tz.local_to_utc(entry.date + schedule_offset)
        b.call(entry, time_to_send.to_time)
      end
    end

    def to_a
      @entries.select(&:sendable?)
    end

    private

    def schedule_offset
      @schedule_offset ||= begin
        now = DateTime.now                                       # today, obviously                            (Apr 19, 5:50pm)
        midnight = DateTime.new(now.year, now.month, now.day)    # get the prev midnight                       (Apr 19 00:00)
        midnight - first_entry_day + 0                           # now - days since first entry +1             (8)
      end
    end

    def first_entry_day
      first_time = @entries.detect { |e| !e.date.nil? }.date     # get the day of the first entry              (Apr 12 9:48am)
      DateTime.new(first_time.year, first_time.month, first_time.day)      # go to the prev midnight                     (Apr 12 00:00)
    end

end
