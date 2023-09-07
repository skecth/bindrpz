class Rule < ApplicationRecord
    mount_uploader :text_rule, RuleUploader
end
