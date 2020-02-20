# frozen_string_literal: true

require 'active_record'
require 'active_support'

namespace :db do
  namespace :migrate do
    desc "Migrates the database by adding partition_guid and encryption_epoch to the specified model (must specify :model)"
    task :add_encryption_fields, [:model] => :environment do |_, args|
      model = args[:model].camelize

      abort 'Need to provide `model` as argument' if model.blank?

      `rails generate migration AddEncryptionKeysTo#{model} partition_guid:string \\
        encryption_epoch:datetime`
    end

    desc "Migrates the database by adding the encryption_keys table"
    task :add_encryption_keys_table do
      `rails generate migration CreateEncryptionKeys guid:string \\
        partition_guid:string \\
        key_epoch:datetime \\
        encrypted_data_encryption_key:string \\
        version:string \\
        created_at:datetime \\
        updated_at:datetime`
    end

    desc 'Migrates the database by generating partition guid and encryption epoch for the specified model'
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

    desc 'Migrates the database by performing read/write to re-encrypt specified attributes for the specified model'
    task :re_encrypt_attributes, %i[model] => :environment do |_t, args|
      model = args[:model].camelize

      abort 'Need to provide `model` as argument' if model.blank?

      model_classname = model.to_s.camelize.singularize.constantize
      encrypted_attributes = model_classname.encrypted_attributes.keys

      model_classname.all.each do |record|
        encrypted_attributes.each do |attribute|
          value = record.send(attribute)
          record.send("#{attribute}=", value) unless value.blank?
        end

        record.save!(validate: false)
      end
    end
  end
end
