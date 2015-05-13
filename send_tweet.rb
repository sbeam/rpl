class SendTweet

  @queue = :tweets

  def self.perform entry
    puts "sending this!: #{entry}"
    File.open('/tmp/tweeeee', 'a') do |f|
      f.puts "sending this!: #{entry}"
    end
  end

end
