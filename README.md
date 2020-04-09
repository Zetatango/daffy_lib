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

There are default implementations of `generate_partition_guid` which returns the linked `User`'s `guid`, as well as a `generate_encryption_epoch` method which defines the encryption epoch, which are the following.

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
  
These work for the general case of a model with encrypted attributes that has a partition provider other than itself, and for an encryption epoch period of 1 year.  They can be overriden if necessary.

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
Next, run `rake db:migrate:add_encryption_fields['modelname']` to add the `partition_guid` and `encryption_epoch` columns to each model.

Run `rake generate_encryption_attributes['modelname','limit']` to populate existing records of each model with the encryption attributes.  The limit specifies the maximum number of records updated per execution; a limit of 0 means no limit.

Finally, once existing records have been populated, it is advisable to perform a final migration to set `partition_guid` and `encryption_epoch` columns to mandatory.


## Development

Development on this project should occur on separate feature branches and pull requests should be submitted. When submitting a pull request, the pull request comment template should be filled out as much as possible to ensure a quick review and increase the likelihood of the pull request being accepted.

### Ruby

This application requires:

*   Ruby version: 2.7.1

Ruby 2.7.1 and greater requires OpenSSL 1.1+. To link to Homebrew's upgraded version of OpenSSL, add the following to your bash profile

```shell script
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
```

If you do not have Ruby installed, it is recommended you use ruby-install and chruby to manage Ruby versions.

```bash
brew install ruby-install chruby
ruby-install ruby 2.7.1
```

Add the following lines to ~/.bash_profile:

```bash
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh
```

Set Ruby version to 2.7.1:

```bash
source ~/.bash_profile
chruby 2.7.1
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Zetatango/daffy_lib.
