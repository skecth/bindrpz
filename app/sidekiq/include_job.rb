class IncludeJob
    include Sidekiq::Job
  
    def perform(filepath)
      feed_zone = FeedZone.find_by(file_path: filepath)
      if feed_zone
        zone = feed_zone.zone
        rpz_path = zone.zone_path
        rpz_rule = "$INCLUDE #{filepath}; \n"
        lines = File.readlines(rpz_path)
  
        unless lines.include?(rpz_rule)
          File.open(rpz_path, 'a') do |file|
            file.write(rpz_rule)
          end
          Rails.logger.info "Added #{rpz_rule} to #{rpz_path}"
        end
      else
        Rails.logger.error "No FeedZone found with file_path: #{filepath}"
      end
    end
  end