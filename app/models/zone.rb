class Zone < ApplicationRecord
    has_many :feed_zones
    validates :name, presence: true, uniqueness: true
    #validates :zone_path, presence: true
    accepts_nested_attributes_for :feed_zones, allow_destroy: true, reject_if: :all_blank
   

end
