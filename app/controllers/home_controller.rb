class HomeController < ApplicationController

  

def show
    @feed = Feed.pluck(:id).first
    puts @feed
end

def index
    @zones= Zone.last(10)
    @categories = Category.last(10)
    @feeds = Feed.last(10)
end

end
