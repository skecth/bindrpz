require "httparty"
require "nokogiri"

class DomainAddJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform
    puts "Time start: #{Time.now}"
    puts "Domain Add Job"
    domains = Domain.all
    links = domains.pluck(:id,:URL,:category,:source, :list_domain)
    links.each do |id, url, cat, source, list_domain| 
      domain=Domain.find(id)
      if domain.list_domain.present? #check if the list domain is exist. if exist puts, if not add new
        puts "Nothing changed"
      else
        response = HTTParty.get(url)
        if response.code == 200
          documents = Nokogiri::HTML(response.body)
          lines = documents.text.split("\n")
          line_to_save =[] #initialize array
          lines.each do |line|
            next if line.strip.start_with?("#") || line=~/^(127|255|:|ff|fe)/ || line.strip.empty? || line=~/\#/ || line=~/127.0.0.1 localhost/
            clean_line = line.strip.gsub(/\b0\.0\.0\.0\b/, '').gsub(/\bwww.\b/, '').gsub(/#.*$/, '') #remove unwanted symbol or logo
            
            #new_line = clean_line.split(/\s/, ' ')
            unless clean_line.empty?
              line_to_save << clean_line
            end
          end
          new_category=cat.capitalize()
          new_source = source.split.map(&:capitalize).join(' ')
          domain.update(list_domain: line_to_save)
          domain.update(source: new_source)
          domain.update(URL: url)
          domain.update(category: new_category)
          puts "Add line: #{domain.URL}"
          
        else
          puts "Not updates: #{domain.URL}"
        end
      end
    end
  end
end

