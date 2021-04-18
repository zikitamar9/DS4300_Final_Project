# API KEY: IaUtgWghekn3RdS8O2ZRq7jo9

# API SECRET KEY: PlCU70HkvSsVOxonrUv5bLBI7gE7n8DRu0ErkslgM84iuOwr3J

# BEARER TOKEN: AAAAAAAAAAAAAAAAAAAAABGNOQEAAAAA0IxoSMc39VguarpOxstYtwHL24Y%3D3ZrcVDv10iyMqEA2ohTvqVACaYBAIq4syD68oapdQxGaoX3eyc
require 'twitter'
require 'csv'
require 'redis'

# To initalize the tweet generator class
class TweetGenerator
  # Constructor
  def initialize(opts = {})
      @opts = {
        :limit                  => 1000,
        :consumer_key           => "IaUtgWghekn3RdS8O2ZRq7jo9",
        :consumer_secret        => "PlCU70HkvSsVOxonrUv5bLBI7gE7n8DRu0ErkslgM84iuOwr3J",
        :access_token           => "1181978587072647169-3RuiEtiuFAONy6BGW1UAxBRmk1Fowc",
        :access_token_secret    => "6vImyFj8hwF64zmhBZ4Kuq0np6jhCNzC9KoDqhk7d14Ba",
        :server                 => {:timeout => 0},
        :channel                => 'hashtag_stream',
      }.merge opts
      @server = Redis.new(@opts[:server])
  end

  # Push hastags to a redis channel
  def publishHashtags
    twitterclient =  Twitter::Streaming::Client.new(@opts);
    count = 0
    twitterclient.sample do |object|
      if count < @opts[:limit]
        if object.is_a?(Twitter::Tweet) && object.hashtags?
          hashtags = object.hashtags
          hashtags.each do |ht|
            count += 1
            text = ht.text
            if text.match(/^[\x20-\x7E]*$/)
              puts("TWEET HASHTAG: #{ht.text}")
              @server.publish @opts[:channel], ht.text
            end
          end
        end
      else
        twitterclient.close
        puts count
      end
    end
  end

end
