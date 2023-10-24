require "httparty"
require "nokogiri"
require "uri"

class DomainUpdateJob
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform
    #get all the feed 
    @domains = Domain.all
    @domains.each do |domain|
      @domain = domain
      if @domain.URL.present?
        @domain.list_domain = Net::HTTP.get(URI.parse(@domain.URL)).split("\n").select{|line| line[0] != '#' && line != ''}.reject{|line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/}.join("\n")
        # @domain.list_domain = Net::HTTP.get(uri).gsub(/[\[\]"]/, '').split("\n").reject { |line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/ }
        @domain.list_domain = @domain.list_domain.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
        @domain.save 
        Rails.logger.info "Domain #{@domain.id} updated automatically"
      end
    end
  end
end

