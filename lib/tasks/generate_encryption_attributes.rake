# frozen_string_literal: true

# :nocov:
namespace :db do
  desc 'this task generates partition guid and encryption epoch for the specified model'
  task :generate_encryption_attributes, %i[model limit] => :environment do |_t, args|
    model = args[:model].camelize
    limit = args[:limit] || 1000
    limit = limit.to_i

    abort 'Need to provide `model` as argument' if model.blank?

    model_classname = model.to_s.camelize.singularize.constantize

    model_classname.instance_eval do
      # Find all records that don't yet have a partition_guid
      scope :pending_migration, -> { where(partition_guid: nil) }
    end

    model_classname.reset_column_information

    records = limit.zero? ? model_classname.pending_migration : model_classname.pending_migration.limit(limit)

    records.each do |record|
      record.generate_partition_guid
      record.generate_encryption_epoch

      record.save!(validate: false)
    end
  end
end
# :nocov:
