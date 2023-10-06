# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DaffyLib::HasEncryptedAttributes do
  describe 'when a subclass does implement the HasEncryptedAttributes abstract methods' do
    it 'does not raise a NoMethodError when generate_partition_guid is implemented' do
      partition_provider = create(:partition_provider)
      proxy = create(:proxy, partition_provider_guid: partition_provider.guid)
      child = create(:child, proxy:)
      expect { child.generate_partition_guid }.not_to raise_error
    end

    it 'does not raise a NoMethodError when generate_encryption_epoch is implemented' do
      partition_provider = create(:partition_provider)
      proxy = create(:proxy, partition_provider_guid: partition_provider.guid)
      child = create(:child, proxy:)
      expect { child.generate_encryption_epoch }.not_to raise_error
    end

    it 'raise a validation error when the partition_guid attribute is changed' do
      partition_provider = create(:partition_provider)
      proxy = create(:proxy, partition_provider_guid: partition_provider.guid)
      child = create(:child, proxy:)
      child.update(partition_guid: 1234)
      expect(child.errors).to include(:partition_guid)
    end

    it 'raise a validation error when the encryption_epoch attribute is changed' do
      partition_provider = create(:partition_provider)
      proxy = create(:proxy, partition_provider_guid: partition_provider.guid)
      child = create(:child, proxy:)
      child.update(encryption_epoch: 1234)
      expect(child.errors).to include(:encryption_epoch)
    end
  end
end
