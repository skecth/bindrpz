class HomeController < ApplicationController

    def show
        @feed = Feed.pluck(:id).first
        puts @feed
    end

    def index
        @zones= current_user.zones
        @categories = Category.all
        @feeds = Feed.all
    end

end
