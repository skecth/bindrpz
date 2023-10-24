class GenerateRpzJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Step 1: Retrieve all the domains from the database
    domains = Domain.all

    # Step 2: Read existing RPZ Zone File Templates
    drop_path = '/etc/bind/db.rpz.local.drop'
    tcp_path = '/etc/bind/db.rpz.local.tcp'
    data_path = '/etc/bind/db.rpz.local.data'
    nxdomain_path = '/etc/bind/db.rpz.local.nxdomain'
    passthru_path = '/etc/bind/db.rpz.local.passthru'

    drop_template = File.read(drop_path, encoding: 'UTF-8')
    tcp_template = File.read(tcp_path, encoding: 'UTF-8')
    data_template = File.read(data_path, encoding: 'UTF-8')
    nxdomain_template = File.read(nxdomain_path, encoding: 'UTF-8')
    passthru_template = File.read(passthru_path, encoding: 'UTF-8')

    # Step 3: Generate RPZ Rules
    drop_rules = ""
    tcp_rules = ""
    data_rules = ""
    nxdomain_rules = ""
    passthru_rules = ""

    domains.each do |domain|
      list_domains = domain.list_domain.split("\n")
      action = domain.action

      list_domains.each do |list_domain|
        # Clean up the domain name
        domain_name = list_domain.to_s.chomp('.').strip

        # Remove the www. from the domain name
        domain_name = domain_name[4..-1] if domain_name.start_with?('www.')

        # Append the rules to the action
        domain_rule = "#{domain_name} #{action}\n"

        # Append the rules to the rpz_rules
        unless domain_name.empty?
          
            if action == 'IN CNAME rpz-drop'
              drop_rules << domain_rule
            elsif action == 'CNAME rpz-tcp-only'
              tcp_rules << domain_rule
            elsif action == 'CNAME *.'
              data_rules << domain_rule
            elsif action == 'CNAME .'
              nxdomain_rules << domain_rule
            elsif action == 'IN CNAME rpz-passthru'
              passthru_rules << domain_rule
            end
          
        end
      end
    end

    # Step 4: Write the RPZ rules to the RPZ zone files
    drop_template << drop_rules
    tcp_template << tcp_rules
    data_template << data_rules
    nxdomain_template << nxdomain_rules
    passthru_template << passthru_rules

    # Step 5: Write RPZ Zone Files
    File.open(drop_path, 'w') do |file|
      file.write(drop_template.lines.uniq.join(""))
    end

    File.open(tcp_path, 'w') do |file|
      file.write(tcp_template.lines.uniq.join(""))
    end

    File.open(data_path, 'w') do |file|
      file.write(data_template.lines.uniq.join(""))
    end

    File.open(nxdomain_path, 'w') do |file|
      file.write(nxdomain_template.lines.uniq.join(""))
    end

    File.open(passthru_path, 'w') do |file|
      file.write(passthru_template.lines.uniq.join(""))
    end

    #add system command to reload bind9
    system('sudo service named restart')
  end
end