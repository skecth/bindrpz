json.extract! feed, :id, :feed_name, :source, :category_id, :created_at, :updated_at, :feed_path, :url
json.url feed_url(feed, format: :json)
