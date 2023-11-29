require "httparty"
require "nokogiri"
require "uri"

class DomainUpdateJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform
    @feeds = Feed.all
    @feeds.each do |feed|
      # create folder
      system("sudo chmod 777 /etc/bind/feed")

      # Dir.mkdir("/etc/bind/feed") unless File.exist?("/etc/bind/feed")
      # check if the file exist or not in the /etc/bind/feed folder
      file = "/etc/bind/feed/#{feed.feed_name}.txt"
      @blacklist_data = Net::HTTP.get(URI.parse(feed.url)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^#|^$/}.join("\n")
      @blacklist_data = @blacklist_data.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/#.*$/, '')
      # if the line has space, then split it 
      @blacklist_data = @blacklist_data.split("\n").map{|line| line.split(' ')}.flatten.join("\n")
      @blacklist_data = @blacklist_data.gsub(/^www\./, '')
      @blacklist_data = @blacklist_data.split("\n").map(&:strip).uniq.join("\n")  #remove duplicate  
      @count = @blacklist_data.split("\n").count
      if File.exist?(file)
        # update file using system command
        system("sudo chmod 777 #{file}")
        File.open(file, "w") do |f|
          f.write(@blacklist_data)
        end
      else
        system("sudo chmod 777 #{file}")
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

