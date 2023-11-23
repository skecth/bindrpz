class FeedZone < ApplicationRecord
    belongs_to :zone
    belongs_to :feed
    belongs_to :category, optional: true
    validates :feed_id, presence: true


    validate :check_domain
    

    def check_domain
      if  selected_action == "IN CNAME rpz-passthru"
          if destination.nil? || !destination.match(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
            errors.add(:destination, "Invalid IP format.")
          end
        end
    end
end
