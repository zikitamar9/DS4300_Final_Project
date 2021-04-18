require_relative 'bloomttl'
require 'redis'

id = 'trendbloom'

bf1 = TrendingFilter.new(:identifier => id + '01')
bf2 = TrendingFilter.new(:identifier => id + '02')

puts "-- #{id}:01 stats --"
bf1.stats
bf1.mostrecent.each do |n|
  print("#{n}\n")
end
puts "-- #{id}:02 stats --"
bf2.stats
bf2.mostrecent.each do |n|
  print("#{n}\n")
end
