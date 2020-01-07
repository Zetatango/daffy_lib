# frozen_string_literal: true

module DaffyLib::PartitionProvider
  extend ActiveSupport::Concern

  class_methods do
    def partition_provider(attribute)
      class_eval do
        cattr_accessor :partition_provider_attribute do
          attribute
        end

        def provider_partition_guid
          provider_info
        end
      end
    end

    def partition_provider_guid(guid_method, model)
      class_eval do
        cattr_accessor :model do
          model
        end

        cattr_accessor :guid_method do
          guid_method
        end

        def provider_partition_guid
          provider_record_info(record)
        end

        private

        def record
          model.find_by(guid: send(guid_method))
        end
      end
    end
  end

  def provider_info
    raise ActiveRecord::RecordInvalid if partition_provider_attribute.nil?

    provider_record_info(send(partition_provider_attribute))
  end

  private

  def provider_record_info(record)
    raise ActiveRecord::RecordInvalid unless record.present? && record.is_a?(DaffyLib::PartitionProvider)

    info = record.send(:provider_partition_guid)

    raise ActiveRecord::RecordInvalid if info.nil?

    info
  end
end
