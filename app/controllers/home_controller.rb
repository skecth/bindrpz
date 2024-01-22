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

        @categories = Category.all
        @feeds = Feed.all
        @feed_used_count = FeedZone.where.not(feed_id: nil).count
        @cateogry_used = FeedZone.where.not(category_id: nil).count
        @cateogry_used_in_custom = CustomBlacklist.where.not(category_id: nil).count

        @total_blacklist=0
        @feeds.each do |feed|
            @total_blacklist = feed.number_of_domain+@total_blacklist
        end        
      
        @top_category_in_feed_zone = nil
        max_feed_count = 0
        if @categories.present?
          @categories.each do |category|
            feedzone_count = category.feed_zones.count if category.feed_zones.present?
          
            if feedzone_count.to_i > max_feed_count
              max_feed_count = feedzone_count
              @top_category_in_feed_zone = category
            end
          end          
        end
        #custom_blacklist
        @top_category_in_custom_blacklist = nil
        max_feed_count = 0
        
        if @categories.present?
          @categories.each do |category|
            # Assuming that category.custom_blacklists returns an ActiveRecord association
            custom_blacklist_count = category.custom_blacklists.count if category.custom_blacklists.present?
            
            if custom_blacklist_count.to_i > max_feed_count
              max_feed_count = custom_blacklist_count
              @top_category_in_custom_blacklist = category
            end
          end
        end
        
       
    end

end
