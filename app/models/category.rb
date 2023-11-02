class Category < ApplicationRecord
    has_many :feeds, dependent: :destroy
    has_many :feed_zones
end
