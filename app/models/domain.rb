class Domain < ApplicationRecord
    belongs_to :feed
    belongs_to :category, optional: true
    enum status: %i[bulk blacklist]
end
