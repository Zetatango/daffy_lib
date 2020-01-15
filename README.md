[![CircleCI](https://circleci.com/gh/Zetatango/daffy_lib.svg?style=svg)](https://circleci.com/gh/Zetatango/daffy_lib) [![codecov](https://codecov.io/gh/Zetatango/daffy_lib/branch/master/graph/badge.svg?token=WxED9350q4)](https://codecov.io/gh/Zetatango/daffy_lib) [![Gem Version](https://badge.fury.io/rb/daffy_lib.svg)](https://badge.fury.io/rb/daffy_lib) 
# DaffyLib

This gem is a caching encryptor which improves performance when encrypting/decrypting large amounts of data.  It will keep a plaintext key cached for a given amount of time, as well as provide partitioning to allow entire rows to be encrypted with the same key.  Keys are uniquely identified by a pair of a partition guid and an encryption epoch.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'daffy_lib'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install daffy_lib

## Usage

We illustrate usage of this library with an example.  Suppose we have classes `User` and `User::Attribute` where attributes belong to users and have values that need to be encrypted.  We wish for `User` to be the partition provider for `User::Attribute`.

The `User` class will need to `include DaffyLib::PartitionProvider` and implement the method `provider_partition_guid` which returns an identifier, for instance a user's `guid`.

The `User::Attribute` class will need to `include DaffyLib::PartitionProvider` as well as `include DaffyLib::HasEncryptedAttributes`.  It will need to declare `partition_provider :user`.  

It then needs to implement a `generate_partition_guid` which returns the linked `User`'s `guid`, as well as a `generate_encryption_epoch` method which defines the encryption epoch.  The suggested implementations are:

  ```
  def generate_partition_guid
    return partition_guid if partition_guid.present?

    self.partition_guid = provider_partition_guid
  end

  def generate_encryption_epoch
    return encryption_epoch if encryption_epoch.present?

    self.encryption_epoch = DaffyLib::KeyManagementService.encryption_key_epoch(Time.now)
  end
  ```

Now suppose the `User::Attributes` has a `values` field to be encrypted.  One declares

```
attr_encrypted :values, encryptor: ZtCachingEncryptor, encrypt_method: :zt_encrypt, decrypt_method: :zt_decrypt,
                        encode: true, partition_guid: proc { |object| object.generate_partition_guid },
                        encryption_epoch: proc { |object| object.generate_encryption_epoch }, expires_in: 5.minutes
```
                                         
where the `expires_in` field denotes how long a plaintext key should be kept in cache.

Note further that a class can be its own partition provider; i.e. if `User` itself had encrypted attributes, all the steps above for `User::Attributes` apply, except there is no need to declare `partition_provider`, and the recommended implementation for `generate_partition_guid` is to return (or create) the `guid` of the `User`.

There are partial rake tasks to assist with the necessary database migrations included.

Run `rake db:migrate:add_encryption_keys_table` to generate the migration file to add the encryption keys table.  Add the following lines for indexing to the generated file.

```
t.index [:guid], name: :index_encryption_keys_on_guid, unique: true
t.index [:partition_guid, :key_epoch], name: :index_encryption_keys, unique: true

```
Next, if the models do not have existing records, one can run `rake db:migrate:add_encryption_fields[modelname]` to add the `partition_guid` and `encryption_epoch` columns.

However, if there may already be existing records, then the `generate_partition_guid` and `generate_encryption_epoch` methods need to be invoked before the new columns can be set to required.  Below is a sample migration file for our example above, where one should replace `models` with their own.
```
  def up
    models = %i[users users/attributes]

    models.each do |model|

      model_classname = model.to_s.camelize.singularize.constantize
      model_tablename = model.to_s.gsub('/', '_')

      add_column model_tablename, :partition_guid, :string
      add_column model_tablename, :encryption_epoch, :datetime

      model_classname.reset_column_information
      model_classname.find_each do |record|
        record.generate_partition_guid
        record.generate_encryption_epoch

        record.save!(validate: false)
      end

      change_column model_tablename, :partition_guid, :string, null: false
      change_column model_tablename, :encryption_epoch, :datetime, null: false
    end
  end

  def down
    models = %i[users users/attributes]

    models.each do |model|
      model_tablename = model.to_s.gsub('/', '_')

      remove_column model_tablename, :partition_guid
      remove_column model_tablename, :encryption_epoch
    end
  end
end
```


## Development

Development on this project should occur on separate feature branches and pull requests should be submitted. When submitting a pull request, the pull request comment template should be filled out as much as possible to ensure a quick review and increase the likelihood of the pull request being accepted.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Zetatango/daffy_lib.

