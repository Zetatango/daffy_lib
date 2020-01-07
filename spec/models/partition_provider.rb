# frozen_string_literal: true

class PartitionProvider < DaffyLib::ApplicationRecord
  include DaffyLib::HasGuid
  include DaffyLib::PartitionProvider

  has_guid 'pp'

  validates_with DaffyLib::StringValidator, fields: %i[guid]

  def provider_partition_guid
    generate_guid
  end
end
