class Category < ApplicationRecord
    has_many :feeds, dependent: :destroy
    has_many :feed_zones
    has_many :custom_blacklists

    validates :name, presence: true, uniqueness: true
    
end
