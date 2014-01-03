require 'dm-core'
require 'dm-redis-adapter'

DataMapper.setup(:default, {:adapter  => "redis"})

class Story
  include DataMapper::Resource

  property :id, Serial
end
