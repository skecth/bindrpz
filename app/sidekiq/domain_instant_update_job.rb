class DomainInstantUpdateJob
  include Sidekiq::Job

  def perform(*args)
    @domain = Domain.find(args[0])
    @domain.list_domain = Net::HTTP.get(URI.parse(@domain.URL)).split("\n").select{|line| line[0] != '#' && line != '' && line[0] != '!'}.reject{|line| line =~ /^:|^ff|^fe|^255|^127|^#|^$/}.join("\n")
    @domain.list_domain = @domain.list_domain.gsub(/^(\b0\.0\.0\.0\s+|127.0.0.1)|^server=\/|\/$|[\|\^]|\t/, '').gsub(/^www\./, '').gsub(/#.*$/, '')
    @domain.list_domain = @domain.list_domain.split("\n").map(&:strip).uniq.join("\n")  #remove duplicate   
    @domain.save 
    Rails.logger.info "Domain #{@domain.id} updated"
  end
end
