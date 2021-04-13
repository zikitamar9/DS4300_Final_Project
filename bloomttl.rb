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

# =============================================================

class TrendingFilter
  def initialize(opts = {})
      @opts = {
        :identifier => 'trendbloom01',
        :size       => 100,
        :hashes     => 4,
        :seed       => 694206942069420,
        :bucket     => 3,
        :ttl        => 180,
        :server     => {:timeout => 0}
      }.merge opts
      @server = Redis.new(@opts[:server])
      @bf = BloomFilter::CountingRedis.new(@opts);
  end

  def addkeyword(keyword)
    @server.lpush("bloomlist", keyword)
    @bf.insert(keyword)
  end

  def addkeywords(lofkeyword)
    for keyword in lofkeyword
      addkeyword(keyword)
    end
  end

  def query(keyword)
    @bf.quant?(keyword)
  end

  def querymultiple(lofkeyword)
    buffer = []
    for keyword in lofkeyword
      buffer.append(@bf.quant?(keyword))
    end
    buffer
  end

  def mostrecent
    result = @server.lrange("bloomlist", 0, 9)
    Array[result, querymultiple(result)]
  end

  def stats()
    @bf.stats
  end
end


# myBf.addkeyword('cats')
# myBf.addkeyword('cats')
# myBf.addkeyword('dog')
# print("QUERY RETURN: ")
# print(myBf.querymultiple(['cats', 'dog']))
# print(" END\n")
# sleep(1)
# myBf.addkeyword('cats')
# print("QUERY RETURN: ")
# print(myBf.querymultiple(['cats', 'dog']))
# print(" END\n")
# sleep(1)
# print("QUERY RETURN: ")
# print(myBf.querymultiple(['cats', 'dog']))
# print(" END\n")
# myBf.addkeyword('cats')
# sleep(1)
# myBf.addkeyword('cats')
# sleep(1)
# myBf.addkeyword('cats')
# sleep(1)
# print("QUERY RETURN: ")
# print(myBf.querymultiple(['cats', 'dog']))
# print(" END\n")
# sleep(2)
# print("QUERY RETURN: ")
# print(myBf.querymultiple(['cats', 'dog']))
# print(" END\n")

# myBf.stats
