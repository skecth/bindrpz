class HomeController < ApplicationController

    def show
        @feed = Feed.pluck(:id).first
        puts @feed
    end

    def index
        @zones= current_user.zones
        @categories = Category.all
        @feeds = Feed.all
        @feed_used_count = FeedZone.where.not(feed_id: nil).count
        @cateogry_used = FeedZone.where.not(category_id: nil).count
        @cateogry_used_in_custom = CustomBlacklist.where.not(category_id: nil).count
        @total = @cateogry_used_in_custom +  @cateogry_used.to_i
        # percentage = ((@total.to_i / @categories.count.to_i) * 100).to_i
        # puts "cat: #{percentage}"
    end

end
