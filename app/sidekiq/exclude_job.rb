class ExcludeJob
  include Sidekiq::Job

  def perform(filepath)
    feed_zone = FeedZone.find_by(file_path: filepath)
    if feed_zone
      zone = feed_zone.zone
      rpz_path = zone.zone_path
      rpz_rule = "$INCLUDE #{filepath};\n"
      lines = File.readlines(rpz_path)
      
      if lines.include?(rpz_rule)
        lines.delete(rpz_rule)
        File.open(rpz_path, 'w') do |file|
          file.write(lines.join)
        end
      else
        Rails.logger.error "No #{rpz_rule} found in #{rpz_path}"
      end
    else
      Rails.logger.error "No FeedZone found with file_path: #{filepath}"
    end
  end
end