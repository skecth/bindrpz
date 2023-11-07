class CustomBlacklist < ApplicationRecord
    enum blacklist_type: [:Domain, :IP]
    mount_uploader :file, AttachmentUploader
    enum action: [:NODATA, :NXDOMAIN, :A, :AAAA]
    enum kind: [:single, :bulk]
end
