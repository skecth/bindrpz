require "httparty"
require "nokogiri"
require "uri"

class DomainUpdateJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform
    # #get all the feed 
    # @domains = Domain.all
    # @domains.each do |domain|
    #   @domain = domain
    #   if @domain.URL.present?

    #     @domain.list_domain = Net::HTTP.get(URI.parse(@domain.URL)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/}.join("\n")
    #     @domain.list_domain = @domain.list_domain.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
    #     @domain.list_domain = @domain.list_domain.split("\n").map(&:strip).uniq.join("\n")  #remove duplicate   
        
    #     if @domain.list_domain.present?
    #       @domain.line_count = @domain.list_domain.split("\n").count
    #     end 
    #     @domain.save 
    #     Rails.logger.info "Domain #{@domain.id} updated automatically"
    #   end
    # end
  end
end

