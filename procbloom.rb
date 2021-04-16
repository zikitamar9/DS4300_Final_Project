require_relative 'bloomttl'

id = 'trendbloom'

bf1 = TrendingFilter.new(:identifier => id + '01')
bf2 = TrendingFilter.new(:identifier => id + '02')

redis2 = Redis.new(:timeout => 0)
id01 = id + '01:'
id02 = id + '02:'
sleeptime = 1
sleep(5)
loop do
  bf1.mostrecent.each do |n|
    print("#{n}\n")
    redis2.publish('out_stream', "#{n}")
  end
  bf2.mostrecent.each do |n|
    print("#{n}\n")
    redis2.publish('out_stream', "#{n}")
  end
  sleep(sleeptime)
end

