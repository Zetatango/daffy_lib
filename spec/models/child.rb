# frozen_string_literal: true

require './spec/models/proxy'
require 'attr_encrypted'

class Child < DaffyLib::ApplicationRecord
  include DaffyLib::PartitionProvider
  include DaffyLib::HasEncryptedAttributes
  include DaffyLib::HasGuid

  partition_provider :proxy

  belongs_to :proxy, required: true

  attr_encrypted :value, partition_guid: proc { |object| object.generate_partition_guid }, encryption_epoch: proc { |object| object.generate_encryption_epoch },
                         encryptor: DaffyLib::CachingEncryptor, encrypt_method: :zt_encrypt, decrypt_method: :zt_decrypt,
                         encode: true, cmk_key_id: 'alias/zetatango', expires_in: 5.minutes

  has_guid 'c'
  validates_with DaffyLib::StringValidator, fields: %i[guid]
end
