require_relative 'bloomttl'

redis = Redis.new(:timeout => 0)
sixtysecBF = TrendingFilter.new()
chan = 'bloom'
puts "== LISTENING ON \'#{chan}\' =="
redis.subscribe(chan) do |on|
   on.message do |channel, msg|
      puts "GOT KEYWORD : #{msg}"
      sixtysecBF.addkeyword(msg)
   end
end