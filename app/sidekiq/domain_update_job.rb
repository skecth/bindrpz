# require "httparty"
# require "nokogiri"

# class DomainUpdateJob
#   include Sidekiq::Worker
#   sidekiq_options queue: "default"

#   def perform
#     puts "Domain Update Job"

#     domains = Domain.all
   
#     links = domains.pluck(:id, :URL, :category, :source, :list_domain)

#     links.each do |id, url, cat, source, list_domain|
#       domain = Domain.find(id)

#       if url.present?
#         response = HTTParty.get(url)

#         if response.code == 200
#           documents = Nokogiri::HTML(response.body)
#           lines = documents.text.split("\n")
#           line_to_save = []

#           lines.each do |line|
#             next if line.strip.start_with?("#") || line =~ /^(255|:|ff|fe)/ || line.strip.empty? || line =~ /127.0.0.1 localhost/
#             clean_line = line.strip.gsub(/^(\b0\.0\.0\.0\b|127.0.0.1)/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
#             whitespace = /\s/

#             if clean_line.match(whitespace)
#               clean_line_split = clean_line.split(/\s+/)
#             else
#               clean_line_split = [clean_line]
#             end

#             clean_line_split.reject!(&:empty?)

#             unless clean_line_split.empty?
#               line_to_save << clean_line_split
#             end
#           end

#           domain.update(list_domain: line_to_save)
#           domain.update(source: source)
#           domain.update(URL: url)
#           domain.update(category: cat)
#           puts "Update line: #{domain.URL}"

#         else
#           puts "Not updated: #{domain.URL}"
#         end
#       else
#         domain.update(list_domain: list_domain)
#         domain.update(source: source)
#         domain.update(category: cat)
#       end
#     end
#   end
# end
