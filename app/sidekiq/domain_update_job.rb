require "httparty"
require "nokogiri"

class DomainUpdateJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform
    puts "Domain Update Job"
    puts "Time start: #{Time.now}"
    domains = Domain.all
    links = domains.pluck(:id,:URL,:category,:source)
    links.each do |id, url, cat, source| #get the id and url
      domain=Domain.find(id)
      response = HTTParty.get(url)
      if response.code == 200
        documents = Nokogiri::HTML(response.body)
        lines = documents.text.split("\n")
         line_to_save =[] #initialize array
         lines.each do |line|
          next if line.strip.start_with?("#") || line=~/^(127|255|:|ff|fe)/ || line.strip.empty?
          clean_line = line.strip.gsub(/\b0\.0\.0\.0\b/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
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
        puts "line: #{domain.URL}"
        
      else
        puts "Not updates: #{domain.URL}"
      end
    end
  end
end

