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
