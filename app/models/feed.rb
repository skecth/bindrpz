class Feed < ApplicationRecord
    has_many :feed_zones
    belongs_to :category
    enum blacklist_type: [:Domain, :IP, :Host, :DNSMASQ]


end
