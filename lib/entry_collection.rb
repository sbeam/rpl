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
