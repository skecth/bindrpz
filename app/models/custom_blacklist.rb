class CustomBlacklist < ApplicationRecord
  enum blacklist_type: [:Domain, :IP]
  enum kind: [:single, :bulk]
  mount_uploader :file, AttachmentUploader


  belongs_to :zone
  belongs_to :category

  has_many_attached :files

  validates :blacklist_type, presence: true
  validates :action, presence: true
  validates :domain, presence: true



  with_options if: :single? do 
    validates :domain, presence: true
    validate :check_domain
  end

  with_options if: :bulk? do
    validates :file, presence: true
    validate :file_format
  end

  def self.action_lists
    {
       "NXDOMAIN" => "CNAME .",
       "NODATA" => "CNAME *.",
       "PASSTHRU" => "CNAME rpz-passthru.",
       "DROP" => "CNAME rpz-drop.",
       "TCP-ONLY" => "CNAME rpz-tcp-only.",
       "CNAME" => "CNAME",
       "A" => "A",
       "AAA" => "AAA"
    }
  end

  def check_domain
    if blacklist_type == "Domain"
      if domain.present? && !domain.match(/^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/)
        errors.add(:domain, "Invalid domain format.")
      end
    elsif blacklist_type == "IP"
      if domain.present? && !domain.match(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
        errors.add(:domain, "Invalid IP format.")
      end
    end
  end


  def file_format
    # the file extension should be csv
    if file.present? && !file.file.extension.downcase.in?(%w(csv))
      errors.add(:file, "Invalid file format. Only CSV is allowed.")
    # file size
  	elsif file.present? && file.file.size > 1.megabytes
      errors.add(:file, "size exceeds 1MB.")
    # only first column has value
    elsif file.present? 
      CSV.foreach(file.path) do |row|
        if row[1].present?
          errors.add(:file, "Invalid file format. Only first column should have value.")
          break
        	end
      end
    end
    
    if errors.blank?
      check_list
    end
  end

  #check files attached
  def file_attached?
    if files.attached?
      return true
    else
      return false
    end
  end

  # check list in the csv file according to the blacklist type
  def check_list
    if blacklist_type == "Domain"
      if file.present?
        CSV.foreach(file.path) do |row|
          # check for all rows if it is a valid domain and only first column has value
          if row[0].present? && !row[0].match(/[A-Za-z0-9.-]+\.[A-Za-z]{2,}/)
            errors.add(:file, "Invalid domain format for bulk.")
            puts row[0] + " is not a valid domain"
            # break the loop
            break
            return
          end
        end
      end
    elsif blacklist_type == "IP"
      if file.present?
        CSV.foreach(file.path) do |row|
          # check for all rows if it is a valid IP
          if row[0].present? && !row[0].match(/\b(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/)
            # if not valid, add error once
            errors.add(:file, "Invalid IP format.")
            # break the loop
            break
            return
          end
        end
      end
    end
  end
	
end
