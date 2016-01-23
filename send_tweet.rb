require 'twitter'

class SendTweet

  @queue = :tweets

  def self.perform entry
    puts "SendTweet [#{Time.now.to_s}] #{entry}"
    twix.update(entry)
  end

  private

  def self.twix
    @twitter ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end

end
