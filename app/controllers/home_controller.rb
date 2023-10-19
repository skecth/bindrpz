class HomeController < ApplicationController

  

def show
    @feed = Feed.pluck(:id).first
    puts @feed
end

def index
    @feeds = Feed.all
    puts @feed
end

end
