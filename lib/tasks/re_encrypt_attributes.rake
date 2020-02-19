# frozen_string_literal: true

# :nocov:
namespace :db do
  desc 'this task performs a db read/write to re-encrypt specified attributes for the specified model'
  task :re_encrypt_attributes, %i[model] => :environment do |_t, args|
    model = args[:model].camelize

    abort 'Need to provide `model` as argument' if model.blank?

    model_classname = model.to_s.camelize.singularize.constantize
    encrypted_attributes = model_classname.encrypted_attributes.keys

    model_classname.all.each do |record|
      encrypted_attributes.each do |attribute|
        value = record.attributes.with_indifferent_access[attribute.to_sym]
        record.send("#{attribute}=", value) unless value.blank?
      end

      record.save!(validate: false)
    end
  end
end
# :nocov:
