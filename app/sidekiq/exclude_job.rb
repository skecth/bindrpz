class ExcludeJob
    include Sidekiq::Job
  
    def perform(filepath)
      zones = Zone.all
      
        zones.each do |zone|
            rpz_path = zone.zone_path
            rpz_rule = "$INCLUDE #{filepath}; \n"
            lines = File.readlines(rpz_path)

            if lines.include?(rpz_rule)
                lines.delete(rpz_rule)
                File.open(rpz_path, 'w') do |file|
                    file.write(lines.join)
                end
            
                Rails.logger.info "Removed #{rpz_rule} from #{rpz_path}"
            end
        end
        

    end
  end