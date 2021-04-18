require_relative 'bloomttl'
require_relative 'tweetgenerator'

id = 'trendbloom'

filter = SecondOrderFilter.new(:identifier => id)

# LISTENING ON TO A STEAM OF KEYWORDS
t1 = Thread.new {
  redis1 = Redis.new(:timeout => 0)
  sixtysecBF = filter.getFirst
  chan = 'hashtag_stream'
  puts "== LISTENING ON \'#{chan}\' =="
  redis1.subscribe(chan) do |on|
     on.message do |channel, msg|
        puts "GOT KEYWORD : #{msg}"
        sixtysecBF.addkeyword(msg)
     end
  end
}

# UPDATING SECOND ORDER BLOOMFILTER
t2 = Thread.new {
  filter.update
}

# STREAMING TWEETS FROM TWITTER.COM
t3 = Thread.new {
  tweetgen = TweetGenerator.new()
  tweetgen.publishHashtags
}

t1.join
t2.join
t3.join
