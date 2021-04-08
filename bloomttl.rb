# require 'bloomfilter-rb'

# bf = BloomFilter::CountingRedis.new(:ttl => 2)

# bf.insert('test')
# print(bf.include?('test'))     # => true

# sleep(2)
# print(bf.include?('test'))     # => false

# bf.stats
require 'redis'
require 'zlib'
module BloomFilter
  class Filter
    def stats
      fp = ((1.0 - Math.exp(-(@opts[:hashes] * size).to_f / @opts[:size])) ** @opts[:hashes]) * 100
      printf "Number of filter buckets (m): %d\n" % @opts[:size]
      printf "Number of bits per buckets (b): %d\n" % @opts[:bucket]
      printf "Number of filter elements (n): %d\n" % size
      printf "Number of filter hashes (k) : %d\n" % @opts[:hashes]
      printf "Raise on overflow? (r) : %s\n" % @opts[:raise].to_s
      printf "Predicted false positive rate = %.2f%\n" % fp
    end
  end

  class CountingRedis < Filter

    def initialize(opts = {})
      @opts = {
        :identifier => 'rbloom',
        :size       => 100,
        :hashes     => 4,
        :seed       => Time.now.to_i,
        :bucket     => 3,
        :ttl        => false,
        :server     => {}
      }.merge opts
      @db = @opts.delete(:db) || ::Redis.new(@opts[:server])
    end

    def insert(key, ttl=nil)
      ttl = @opts[:ttl] if ttl.nil?

      indexes_for(key).each do |idx|
        @db.incr idx
        @db.expire(idx, ttl) if ttl
      end
    end
    alias :[]= :insert

    def delete(key)
      indexes_for(key).each do |idx|
        count = @db.decr(idx).to_i
        if count <= 0
          @db.del(idx)
          @db.setbit(idx, 0) if count < 0
        end
      end
    end

    def include?(*keys)
      indexes = keys.collect { |key| indexes_for(key) }
      not @db.mget(*indexes.flatten).include? nil
    end
    alias :key? :include?

    def quant?(*keys)
      indexes = keys.collect { |key| indexes_for(key) }
      @db.mget(*indexes.flatten).map(&:to_i).min()
    end

    def num_set
      @db.eval("return #redis.call('keys', '#{@opts[:identifier]}:*')")
    end
    alias :size :num_set

    def clear
      @db.flushdb
    end

    private

      # compute index offsets for provided key
      def indexes_for(key)
        indexes = []
        @opts[:hashes].times do |i|
          indexes.push @opts[:identifier] + ":" + (Zlib.crc32("#{key}:#{i+@opts[:seed]}") % @opts[:size]).to_s
        end

        indexes
      end
  end
end

# require 'bloomfilter-rb'

class Test
  def initialize(ttl) 
      @bf = BloomFilter::CountingRedis.new(:size => 10, :ttl => ttl);
      print("--INIT BLOOMFILTER OBJ--\n")
  end

  def addHashtag(hashtag)
    @bf.insert(hashtag)
  end

  def addHashtags(lofhashtag)
    for hashtag in lofhashtag
      addHashtag(hashtag)
    end
  end

  def query(hashtag)
    @bf.quant?(hashtag)
  end

  def querymultiple(lofhashtag)
    buffer = []
    for hashtag in lofhashtag
      buffer.append(@bf.quant?(hashtag))
    end
    buffer
  end

  # def include?(hashtag)
  #   @bf.include?(hashtag)
  # end

  def stats()
    @bf.stats
  end

end

myBf = Test.new(2)
myBf.addHashtag('cats')
myBf.addHashtag('cats')
myBf.addHashtag('dog')
print("QUERY RETURN: ")
print(myBf.querymultiple(['cats', 'dog']))
print(" END\n")
sleep(1)
myBf.addHashtag('cats')
print("QUERY RETURN: ")
print(myBf.querymultiple(['cats', 'dog']))
print(" END\n")
sleep(1)
print("QUERY RETURN: ")
print(myBf.querymultiple(['cats', 'dog']))
print(" END\n")
myBf.addHashtag('cats')
sleep(1)
myBf.addHashtag('cats')
sleep(1)
myBf.addHashtag('cats')
sleep(1)
print("QUERY RETURN: ")
print(myBf.querymultiple(['cats', 'dog']))
print(" END\n")
sleep(2)
print("QUERY RETURN: ")
print(myBf.querymultiple(['cats', 'dog']))
print(" END\n")

myBf.stats