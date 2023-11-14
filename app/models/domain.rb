class Domain < ApplicationRecord
    enum status: %i[bulk blacklist]
end
