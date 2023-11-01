class HomeController < ApplicationController

  

def show
    @feed = Feed.pluck(:id).first
    puts @feed
end

def index
    @zone = Zone.first
end

end
