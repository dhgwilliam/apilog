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

  def self.take(int)
    sorted_stories = self.order_by(:time_added => :desc)
    bucket = sorted_stories.inject({}) do |acc, story| 
      date_bucket = story.time_added.strftime("%Y-%m-%d")
      acc[date_bucket] = [] unless acc[date_bucket]
      acc[date_bucket] << story
      acc
    end
    bucket.take int
  end

end
