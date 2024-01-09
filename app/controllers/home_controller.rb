class HomeController < ApplicationController

    def show
        @feed = Feed.pluck(:id).first
        puts @feed
    end

    def index
        @zones= current_user.zones
        @categories = Category.all
        @feeds = Feed.all
        @custom_blacklist = CustomBlacklist.all
        @users = User.all
    end

end
