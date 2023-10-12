class ApplicationController < ActionController::Base

    
def index
    @feeds = Feed.all
end

def show
    # Fetch a specific feed by its ID
    @feed = Feed.find(params[:id])
end

end
