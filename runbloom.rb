require_relative 'bloomttl'

id = 'trendbloom'

t1 = Thread.new {
  redis1 = Redis.new(:timeout => 0)
  sixtysecBF = TrendingFilter.new(:identifier => id + '01')
  chan = 'hashtag_stream'
  puts "== LISTENING ON \'#{chan}\' =="
  redis1.subscribe(chan) do |on|
     on.message do |channel, msg|
        puts "GOT KEYWORD : #{msg}"
        sixtysecBF.addkeyword(msg)
     end
  end
}

t2 = Thread.new {
  redis2 = Redis.new(:timeout => 0)
  id01 = id + '01:'
  id02 = id + '02:'
  ttl = 900
  decay = false
  sleeptime = 180
  sleep(5)
  loop do
    puts "\t-- second order bloom filter --"
    redis2.keys(id01 + "\*").each do |key|
      newkey = id02 + key[id01.length..-1]
      puts("\t\t#{newkey} ")
      defval = 1
      defval = 2 if decay
      incval = defval
      redis2.incrby(newkey, incval)
      redis2.expire(newkey, ttl)
    end
    if decay
      redis2.keys(id02 + "\*").each do |key|
        redis2.decr(key)
        redis2.del(key) if redis2.get(key) <= "0"
      end
    end
    puts "\t-- sleeping for #{sleeptime} --"
    sleep(sleeptime)
  end
}

t1.join
t2.join
