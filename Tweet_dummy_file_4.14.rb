#

# API KEY: IaUtgWghekn3RdS8O2ZRq7jo9

# API SECRET KEY: PlCU70HkvSsVOxonrUv5bLBI7gE7n8DRu0ErkslgM84iuOwr3J

# BEARER TOKEN: AAAAAAAAAAAAAAAAAAAAABGNOQEAAAAA0IxoSMc39VguarpOxstYtwHL24Y%3D3ZrcVDv10iyMqEA2ohTvqVACaYBAIq4syD68oapdQxGaoX3eyc

puts 'Hello World'

require 'twitter'

require 'csv'

require 'redis'

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = "IaUtgWghekn3RdS8O2ZRq7jo9"
  config.consumer_secret     = "PlCU70HkvSsVOxonrUv5bLBI7gE7n8DRu0ErkslgM84iuOwr3J"
  config.access_token        = "1181978587072647169-3RuiEtiuFAONy6BGW1UAxBRmk1Fowc"
  config.access_token_secret = "6vImyFj8hwF64zmhBZ4Kuq0np6jhCNzC9KoDqhk7d14Ba"
end

if "المكابرة".match(/^[\x20-\x7E]*$/)
  puts "Match found!"
else
  print('nah fam')
end

if "asdf".match(/^[\x20-\x7E]*$/)
  puts "Match found!"
else
  print('nah fam')
end


count = 0
h_list = []

connection = Redis.new
client.sample do |object|
  if count < 10000
    if object.is_a?(Twitter::Tweet) && object.hashtags?
      hashtags = object.hashtags
      count = count + 1
      hashtags.each do |ht|
        text = ht.text
        if text.match(/^[\x20-\x7E]*$/)
          h_list.append(ht.text)
          connection.publish 'hashtag_stream', ht.text
        end
      end
    else
      # print('not a tweet')
      count = count + 1
    end
  else
    client.close
    puts count
  end

end
# print(h_list)



# #write all hashtags to a file
# File.open("hashtags_file_test.txt", "w+") do |f|
#   f.puts(h_list)
# end


# tweets = client.user_timeline('rubyinside', count: 4)
#
# tweets.each { |tweet| puts tweet.full_text }

# puts tweets
