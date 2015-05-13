require_relative 'log_entry'

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
end
