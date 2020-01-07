# frozen_string_literal: true

require 'daffy_lib/validators/string_validator'

class DaffyLib::EncryptionKey < DaffyLib::ApplicationRecord
  include DaffyLib::HasGuid

  has_guid 'dek'

  validates :partition_guid, presence: true, allow_blank: false
  validates :key_epoch, presence: true, allow_blank: false, uniqueness: { scope: :partition_guid }
  validates :encrypted_data_encryption_key, presence: true, allow_blank: false
  validates :version, presence: true, allow_blank: false

  validates_with DaffyLib::StringValidator, fields: %i[guid partition_guid encrypted_data_encryption_key version]
end
