class Domain < ApplicationRecord
    belongs_to :feed
    enum status: %i[bulk blacklist]
end
