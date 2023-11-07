json.extract! custom_blacklist, :id, :file, :category, :blacklist_type, :action, :destination, :domain, :kind, :created_at, :updated_at
json.url custom_blacklist_url(custom_blacklist, format: :json)
