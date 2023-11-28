class IncludeJob
    include Sidekiq::Job
  
    def perform(file_path)
      feed_zone = FeedZone.find_by(file_path: file_path)
      if feed_zone
        zone = feed_zone.zone
        rpz_path = zone.zone_path
        rpz_rule = "$INCLUDE #{file_path}; \n"
        lines = File.readlines(rpz_path)
  
        unless lines.include?(rpz_rule)
          File.open(rpz_path, 'a') do |file|
            file.write(rpz_rule)
          end
          Rails.logger.info "Added #{rpz_rule} to #{rpz_path}"
        end
      else
        Rails.logger.error "No FeedZone found with file_path: #{file_path}"
      end
    end
  end