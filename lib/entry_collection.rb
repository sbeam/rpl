require_relative 'log_entry'
require 'date'

class EntryCollection
    #include Enumerable
    #

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
    end

    def cleaned
      @entries.reject(&:is_personal?).map(&:clean)
    end

    def entry_time_offset
      @entry_time_offset ||= begin
        now = DateTime.now                                                 # today, obviously                            (Apr 19, 5:50pm)
        midnight = DateTime.new(now.year, now.month, now.day)              # get the prev midnight                       (Apr 19 00:00)
        midnight - first_entry_day + 1                                     # now - days since first entry +1             (8)
      end
    end

    private

    def first_entry_day
      first_time = @entries.detect { |e| !e.date.nil? }.date               # get the day of the first entry              (Apr 12 9:48am)
      DateTime.new(first_time.year, first_time.month, first_time.day)      # go to the prev midnight                     (Apr 12 00:00)
    end

end
