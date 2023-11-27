class FeedZone < ApplicationRecord
    belongs_to :zone
    belongs_to :feed
    belongs_to :category, optional: true
    validates :feed_id, presence: { message: "Please choose the feed" }, allow_blank: false
    validates :selected_action, presence: { message: "Please choose the action" }, allow_blank: false
    #check if feed_id is already exist in specific zone
    validates :feed_id, uniqueness: { scope: :zone_id, message: "Feed already exist" }


    validate :check_action
    

    def check_action
      if  selected_action == "IN CNAME rpz-passthru"
          if destination.nil? || !destination.match(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
            errors.add(:destination, "Invalid IP format.")
          end
        end
    end

   

    


    
end
