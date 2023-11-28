class HomeController < ApplicationController

  

def show
    @feed = Feed.pluck(:id).first
    puts @feed
end

def index
    @zones= Zone.last(10)
    @categories = Category.last(10)
    @feeds = Feed.all
    @line_counts = {} # Initialize a hash to store line counts for each feed

    @feeds.each do |feed|
      path = feed.feed_path
      output = `sudo wc -l < #{path}` # Backticks execute the command and capture its output
      match_data = output.match(/\d+/) 
      line_count = match_data[0].to_i # Extract the line count
      @line_counts[feed.feed_name] = line_count # Store line count in the hash with feed_name as key
    end
end

end
