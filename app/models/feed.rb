class Feed < ApplicationRecord
    has_many :feed_zones
    belongs_to :category
end
