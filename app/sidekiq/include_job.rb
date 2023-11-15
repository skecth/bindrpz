class IncludeJob
    include Sidekiq::Job
  
    def perform(filepath)
      zones = Zone.all
      
        zones.each do |zone|
            rpz_path = zone.zone_path
            rpz_rule = "$INCLUDE #{filepath}; \n"
            lines = File.readlines(rpz_path)
            unless lines.include?(rpz_rule)
                lines << rpz_rule
                File.open(rpz_path, 'a') do |file|
                    file.write(rpz_rule)
                end
            end
                Rails.logger.info "Added #{rpz_rule} to #{rpz_path}"
        end
        

    end
  end