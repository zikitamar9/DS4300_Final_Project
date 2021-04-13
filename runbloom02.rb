require 'redis'

redis = Redis.new(:timeout => 0)
identifier = "trendbloom01:"
ttl = 1800
sleeptime = 180
loop do
  redis.keys(identifier + "\*").each do |key|
    newkey = "trendbloom02:" + key[identifier.length..-1]
    puts("#{newkey} ")
    redis.incr(newkey)
    redis.expire(newkey, ttl)
  end
  sleep(sleeptime)
end
# sixtysecBF = TrendingFilter.new(60)
# chan = 'bloom'
# puts "== LISTENING ON \'#{chan}\' =="
# redis.subscribe(chan) do |on|
#    on.message do |channel, msg|
#       puts "GOT KEYWORD : #{msg}"
#       sixtysecBF.addkeyword(msg)
#    end
# end