class HomeController < ApplicationController

    def show
        @feed = Feed.pluck(:id).first
        puts @feed
    end

    def index
        @zones= current_user.zones
        @zones = current_user.zones
        @all_custom_blacklists = []

        @zones.each do |zone|
        @all_custom_blacklists.concat(zone.custom_blacklists.ids)
        end

        puts "cussdfsd: #{@all_custom_blacklists}"
        @categories = Category.all
        @feeds = Feed.all
        @feed_used_count = FeedZone.where.not(feed_id: nil).count
        @cateogry_used = FeedZone.where.not(category_id: nil).count
        @cateogry_used_in_custom = CustomBlacklist.where.not(category_id: nil).count

        @total = @cateogry_used_in_custom +  @cateogry_used.to_i
        puts "total: #{@cateogry_used_in_custom}"

        @top_category_in_feed = nil
        max_feed_count = 0
        @categories.each do |category|
          feed_count = category.feeds.count
        
          if feed_count > max_feed_count
            max_feed_count = feed_count
            @top_category_in_feed = category
          end
        end
        #feed_zone
        @top_category_in_feed_zone = nil
        max_feed_count = 0
        @categories.each do |category|
          feedzone_count = category.feed_zones.count
        
          if feedzone_count > max_feed_count
            max_feed_count = feedzone_count
            @top_category_in_feed_zone = category
          end
        end
        #custom_blacklist
        @top_category_in_custom_blacklist = nil
        max_feed_count = 0
        @categories.each do |category|
          custom_blacklist_count = category.custom_blacklists.count
        
          if custom_blacklist_count > max_feed_count
            max_feed_count = custom_blacklist_count
            @top_category_in_custom_blacklist = category
          end
        end
        #top feed
        @top_feed = nil
        top_feed_count = 0
        @feed_zones = FeedZone.all
        @feed_zones.each do |fz|
          max_feed_count = fz.feed.count
          if max_feed_count > top_feed_count
            top_feed_count = max_feed_count
            @top_feed = fz
          end
        end
        @total_blacklist=0
        @feeds.each do |feed|
            @total_blacklist = feed.number_of_domain+@total_blacklist
        end
              
        # percentage = ((@total.to_i / @categories.count.to_i) * 100).to_i
        # puts "cat: #{percentage}"
    end

end
