class Category < ApplicationRecord
    has_many :feeds, dependent: :destroy
    has_many :feed_zones
    has_many :custom_blacklists
    accepts_nested_attributes_for :feed_zones, allow_destroy: true, reject_if: :all_blank
    validates :name, presence: true, uniqueness: true
    
end
