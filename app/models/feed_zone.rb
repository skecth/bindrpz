class FeedZone < ApplicationRecord
    belongs_to :zone
    belongs_to :feed
    belongs_to :category, optional: true
    validates :selected_action, presence: { message: "Please choose the action" }, allow_blank: false
    #check if feed_id is already exist in specific zone
    # validates :feed_id, uniqueness: { scope: :zone_id }
    #  validates :destination, presence: { message: "Please choose the feed" }, allow_blank: false
 
    validate :check_action
    

  
    def check_action
      if  selected_action == "CNAME"
        if destination.nil? || !(
            destination.match(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/) ||
            destination.match(/^([a-zA-Z0-9-]+\.){1,}[a-zA-Z]{2,}$/) ||
            destination.match(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
          )
            errors.add(:destination, "Invalid IP format.")
        end
      end
    end 

end
