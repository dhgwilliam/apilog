require 'apilog/story'

class PocketStory < Story
  field :pocket_id, 
    :type     => Integer,
    :required => true,
    :unique   => true
  field :url, 
    :type     => String,
    :required => true
  field :title, 
    :type     => String,
    :required => true
  field :time_added, 
    :type     => Time,
    :required => true
  field :time_read, 
    :type     => Time
end
