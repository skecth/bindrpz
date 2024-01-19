class DomainUpdateJob
  require "httparty"
  require "nokogiri"
  require "uri"
  include Sidekiq::Job

  def perform(*args)
    @feeds = Feed.all
    @feeds.each do |feed|
      file = "/etc/bind/feed/#{feed.feed_name}.txt"
      @blacklist_data = Net::HTTP.get(URI.parse(feed.url)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^#|^$/}.join("\n")
      if feed.AdGuard?
        @blacklist_data = @blacklist_data.split("\n").reject{|line| line.start_with?('@@')}.join("\n")
      end
      @blacklist_data = @blacklist_data.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/#.*$/, '')
      # if the line has space, then split it 
      @blacklist_data = @blacklist_data.split("\n").map{|line| line.split(' ')}.flatten.join("\n")
      # remove the last dot at the end of the line
      @blacklist_data = @blacklist_data.gsub(/\.$/, '')
      # @blacklist_data = @blacklist_data.gsub(/^www\./, '')
      @blacklist_data = @blacklist_data.split("\n").map(&:strip).uniq.join("\n")  #remove duplicate  
      @count = @blacklist_data.split("\n").count
      if File.exist?(file)
        File.open(file, "w") do |f|
          # check if the file have the same content as the new data
          if File.read(file) == @blacklist_data
            # if the file have the same content as the new data, then do nothing
          else
            # if the file does not have the same content as the new data, then write to file            
            f.write(@blacklist_data)
          end
        end
      else
        # create file
        File.new(file, "w")
        # give permission to create file
        File.chmod(0777, file)
        # write to file
        File.open(file, "w") do |f|
          f.write(@blacklist_data)
        end
      end
      # update the updated_at column
      feed.update(updated_at: Time.now)
      # update the number_of_domain column
      feed.update(number_of_domain: @count)
    end
    #
  end
end


