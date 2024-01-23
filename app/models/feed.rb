class Feed < ApplicationRecord
	has_many :feed_zones, dependent: :restrict_with_error
	belongs_to :category
	enum blacklist_type: [:Domain, :IP, :Host, :DNSMASQ, :AdGuard]
	
	before_validation :generate_feed_name, on: :create
	validates :source, presence: true
	validates :blacklist_type, presence: true
	validates :feed_path, presence: true
	validates :category_id, presence: true
	validates :url, presence: true, uniqueness: true
	validates :feed_name, presence: true, uniqueness: true
	validate :validate_link, on: :create

	def validate_link
		if self.url.present?
			@feed = self
	    # check if link is valid
	    uri = URI.parse(@feed.url)
	    http = Net::HTTP.new(uri.host, uri.port)
	    http.use_ssl = true if uri.scheme == 'https' 
	    request = Net::HTTP::Get.new(uri.request_uri)
	    response = http.request(request)
	    if response.code.to_i != 200
	      render :new, status: :unprocessable_entity, notice: "Feed url is invalid."
	      return
	    else
	      @data = []
	      host_pattern = Regexp.new(/^0\.0\.0\.0\s+([^\s#]+) | ^127\.0\.0\.1\s+([^\s#]+)/x) # regex for host file
	      domain_pattern = Regexp.new(/^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/) # regex for domain
	      ip_pattern = Regexp.new(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/) # regex for ip
	      dnsmasq_pattern = Regexp.new(/server=\/(.*?)\//) # regex for dnsmasq
				adguard_pattern = Regexp.new(/\|\|([A-Za-z0-9.-]+\.[A-Za-z]{2,})\^/) # regex for adguard
  
	      Net::HTTP.get_response(URI.parse(@feed.url)) do |res|
	        # check 100 lines only for performance
	        res.body.lines.first(100).each do |line|
	          next if line.start_with?('#') || line.strip.empty? || line.start_with?('!') || line =~ /^:|^ff|^fe|^255|^$/ || line.include?('localhost')
	          case @feed.blacklist_type
	          when "Host"
	            @data << line.split('#')[0].strip if line.match(host_pattern) && !line.nil?
	          when "DNSMASQ"
	            @data << line if line.match(dnsmasq_pattern) && !line.nil?
	          when "IP"
	            @data << line if line.match(ip_pattern) && !line.nil? && !line.match(/[a-zA-Z]/)
	          when "Domain"
	            @data << line if line.match(domain_pattern) && !line.nil?
						when "AdGuard"
							@data << line if line.match(adguard_pattern) && !line.nil?
							Rails.logger.debug "#{line}"
	          end      
	        end
	      end
	      # validate that data is not empty
				if @data.empty?
					errors.add(:url, "and blacklist type do not match.")
					# return
				end
	
	    end
		end
	end

	def generate_feed_name
		self.feed_name = "#{self.category.name}_#{self.source}" if category.present? && source.present?
		self.feed_name.upcase! if self.feed_name.present?
		self.feed_path = "/etc/bind/feed/#{self.feed_name}.txt"
	end
	


end
