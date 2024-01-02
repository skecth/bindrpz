class FeedZone < ApplicationRecord
    belongs_to :zone
    belongs_to :feed
    belongs_to :category, optional: true
    validates :selected_action, presence: { message: "Please choose the action" }, allow_blank: false
    #check if feed_id is already exist in specific zone
    # validates :feed_id, uniqueness: { scope: :zone_id }
    #  validates :destination, presence: { message: "Please choose the feed" }, allow_blank: false
 
    validate :check_action
    

  
    def check_action(categories_params)
      categories_params.each do |category_id, category_data|
        selected_action = category_data[:selected_action]
        destination = category_data[:destination]
    
        next if selected_action != "CNAME" || destination.blank?
    
        unless valid_destination?(destination)
          errors.add(:destination, "Invalid format for category ID #{category_id}")
        end
      end
    end
    
    private
    
    def valid_destination?(destination)
      # Your destination validation logic here
      # Example regex checks for IP or domain format
      ip_regex = /\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
      domain_regex = /^([a-zA-Z0-9-]+\.){1,}[a-zA-Z]{2,}$/
    
      ip_regex.match(destination) || domain_regex.match(destination)
    end
    

end