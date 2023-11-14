class Zone < ApplicationRecord
    has_many :feed_zones

    validates :name, presence: true, uniqueness: true
    #validates :zone_path, presence: true
end
