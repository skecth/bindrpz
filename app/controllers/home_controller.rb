class HomeController < ApplicationController

  

def show
    @feed = Feed.pluck(:id).first
    puts @feed
end

def index
    @zones= Zone.all
    @categories = Category.all
    @feeds = Feed.all
end

end
