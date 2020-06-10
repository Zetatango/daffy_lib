# frozen_string_literal: true

require './spec/models/partition_provider'

class Proxy < DaffyLib::ApplicationRecord
  include DaffyLib::HasGuid
  include DaffyLib::PartitionProvider

  partition_provider_guid :partition_provider_guid, PartitionProvider

  has_guid 'p'
  validates_with DaffyLib::StringValidator, fields: %i[guid value]
end
