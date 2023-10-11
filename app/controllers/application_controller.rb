class ApplicationController < ActionController::Base


def index
    @feeds = Feed.all
end

end
