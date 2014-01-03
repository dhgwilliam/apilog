require 'pocket'
require 'apilog/story'

class PocketStory < Story
  property :pocket_id, Integer
  property :resolved_url, String
  property :resolved_title, String
  property :time_added, DateTime
  property :time_read, DateTime

  self.raise_on_save_failure = true
end
