require "httparty"
require "nokogiri"

class DomainUpdateJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform
    puts "Domain Update Job"
    puts "Time start: #{Time.now}"
    domains = Domain.all
    links = domains.pluck(:id,:URL,:category,:source) #get the id, url, category, source
    links.each do |id, url, cat, source| #loop to get individual domain
      domain=Domain.find(id)
      response = HTTParty.get(url)
      if response.code == 200
        documents = Nokogiri::HTML(response.body)
        lines = documents.text.split("\n")
         line_to_save =[] #initialize array
         lines.each do |line|
          next if line.strip.start_with?("#") || line=~/^(255|:|ff|fe)/ || line.strip.empty? || line=~/127.0.0.1 localhost/ #remove anything start w/ 
          clean_line = line.strip.gsub(/^(\b0\.0\.0\.0\b|127.0.0.1)/, '').gsub(/^www\./, '').gsub(/#.*$/, '') #remove unwanted symbol or phrase
          whitespace = /\s/
          if clean_line.match(whitespace)
            clean_line_split=clean_line.split(/\s+/)
          else
            clean_line_split = [clean_line]
          end
          clean_line_split.reject!(&:empty?)

          unless clean_line_split.empty?
            line_to_save << clean_line_split
          end
         end
         new_category=cat.capitalize() #capitalize if user not capitalize
         new_source = source.split.map(&:capitalize).join(' ') #capitalize each word and join
         domain.update(list_domain: line_to_save)
         domain.update(source: new_source)
         domain.update(URL: url)
         domain.update(category: new_category)
        puts "Update line: #{domain.URL}"
        
      else
        puts "Not updates: #{domain.URL}"
      end
    end
  end
end

