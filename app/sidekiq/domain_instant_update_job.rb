class DomainInstantUpdateJob
  include Sidekiq::Job

  def perform(*args)
    @domain = Domain.find(args[0])
    @domain.list_domain = Net::HTTP.get(URI.parse(@domain.URL)).split("\n").select{|line| line[0] != '#' && line != ''}.reject{|line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/}.join("\n")
        # @domain.list_domain = Net::HTTP.get(uri).gsub(/[\[\]"]/, '').split("\n").reject { |line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/ }
    @domain.list_domain = @domain.list_domain.gsub(/^(\b0\.0\.0\.0\b|127.0.0.1)/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
    @domain.save 
    Rails.logger.info "Domain #{@domain.id} updated"
  end
end
