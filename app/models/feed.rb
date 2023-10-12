class Feed < ApplicationRecord
    has_many :domains, dependent: :destroy
end
