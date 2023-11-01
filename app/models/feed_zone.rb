class FeedZone < ApplicationRecord
    belongs_to :zone
    belongs_to :feed
    belongs_to :category, optional: true
end
