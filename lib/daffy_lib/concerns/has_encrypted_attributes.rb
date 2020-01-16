# frozen_string_literal: true

module DaffyLib::HasEncryptedAttributes
  extend ActiveSupport::Concern

  included do
    before_create :generate_partition_guid, :generate_encryption_epoch

    validate :ensure_encryption_info_does_not_change
  end

  def generate_partition_guid
    return partition_guid if partition_guid.present?

    self.partition_guid = provider_partition_guid
  end

  def generate_encryption_epoch
    return encryption_epoch if encryption_epoch.present?

    self.encryption_epoch = DaffyLib::KeyManagementService.encryption_key_epoch(Time.now)
  end

  private

  def ensure_encryption_info_does_not_change
    return if new_record?

    errors.add(:partition_guid, 'cannot be changed for persisted records') if partition_guid_changed?
    errors.add(:encryption_epoch, 'cannot be changed for persisted records') if encryption_epoch_changed?
  end
end
