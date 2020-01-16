# frozen_string_literal: true

require 'spec_helper'
require 'timecop'

RSpec.describe Child, type: :model do
  let(:partition_provider) { create :partition_provider }
  let(:proxy) { create :proxy, partition_provider_guid: partition_provider.guid }
  let(:child) { create :child, proxy: proxy }

  it 'requires a proxy' do
    expect { described_class.create! }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it 'can be created with a proxy' do
    expect { described_class.create!(proxy: proxy) }.not_to raise_error
  end

  it 'has a guid' do
    expect(described_class.create!(proxy: proxy)).to respond_to(:guid)
  end

  it 'has valid guid format' do
    expect(described_class.validation_regexp).to match(child.guid)
  end

  it 'has value as an encrypted attribute' do
    expect(child.encrypted_attributes.keys).to include(:value)
  end

  describe '#partition_guid' do
    it 'returns the owner partition guid as the provider partition guid' do
      expect(child.partition_guid).to eq(partition_provider.guid)
    end

    it 'sets a guid on create when it is blank' do
      child = build :child, proxy: proxy, partition_guid: ''
      child.save!
      expect(child.send(:partition_guid)).not_to be_blank
    end

    it 'sets a guid on create when it is nil' do
      child = build :child, proxy: proxy, partition_guid: nil
      child.save!
      expect(child.send(:partition_guid)).not_to be_blank
    end

    it 'cannot be changed' do
      expect do
        child = create :child, proxy: proxy
        child.send("partition_guid=", SecureRandom.base58(16))
        child.save!
      end.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe '#encryption_epoch' do
    it 'sets the encryption epoch to the current epoch' do
      expect(child.encryption_epoch).to eq(DaffyLib::KeyManagementService.encryption_key_epoch(Time.now))
    end

    it 'has a different epoch when created one year later' do
      child.generate_encryption_epoch

      Timecop.freeze(Time.now + 1.year) do
        new_child = build :child, proxy: proxy
        new_child.save!
        expect(new_child.encryption_epoch).to eq(child.encryption_epoch + 1.year)
      end
    end

    it 'sets an encryption epoch on create when it is blank' do
      child = build :child, proxy: proxy, encryption_epoch: ''
      child.save!
      expect(child.send(:encryption_epoch)).not_to be_blank
    end

    it 'sets an encryption epoch on create when it is nil' do
      child = build :child, proxy: proxy, encryption_epoch: nil
      child.save!
      expect(child.send(:encryption_epoch)).not_to be_blank
    end

    it 'cannot be changed' do
      expect do
        child = create :child, proxy: proxy
        child.send("encryption_epoch=", SecureRandom.base58(16))
        child.save!
      end.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe '#provider_partition_guid' do
    it 'returns the partition_provider partition guid as the provider partition guid' do
      expect(child.provider_partition_guid).to eq(partition_provider.guid)
    end

    it 'raises an exception when proxy is nil' do
      child = build :child, proxy: nil

      expect { child.provider_partition_guid }.to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
