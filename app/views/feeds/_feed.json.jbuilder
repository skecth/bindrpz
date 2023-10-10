json.extract! feed, :id, :action, :domain, :created_at, :updated_at
json.url feed_url(feed, format: :json)
