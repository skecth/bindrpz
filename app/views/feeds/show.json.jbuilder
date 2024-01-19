json.array! @blacklist_data do |data|
  json.data data
end


json.array!([@feed]) do |feed|
  json.id feed.id
  json.feed_name feed.feed_name
  # Add other attributes as needed
end