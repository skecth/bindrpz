json.extract! feed, :id,:blacklist_type,:source, :url,:feed_name,:feed_path,:created_at, :updated_at
json.url feed_url(feed, format: :json)
