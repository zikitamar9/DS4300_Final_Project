require_relative 'bloomttl'

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

# Ruby program for log() function 
  
# Assigning values
val1 = 213
val2 = 256
base2 = 2
  
val3 = 27 
base3 = 3
  
val4 = 100 
base4 = 10
  
# Prints the value returned by log() 
puts Math.log(val1)
  
puts Math.log(val2, base2)
  
puts Math.log(val3, base3)
  
puts Math.log(val4, base4)
