# frozen_string_literal: true

require 'spec_helper'
require 'byebug'

RSpec.describe Proxy, type: :model do
  let(:proxy) { create :proxy }

  describe 'string validator' do
    it 'fails validation if attribute contains invalid characters' do
      proxy.value = '<script>do_bad</script>'
      expect(proxy).not_to be_valid
      expect(proxy.errors[:value].first).to eq('contains invalid characters...')
    end

    it 'passes validation if attribute does not contain invalid characters' do
      proxy.value = 'value'
      expect(proxy).to be_valid
    end

    it 'does not validate value if not changed' do
      proxy.update_attribute('value', '<script>do_bad</script>')
      expect(proxy.reload).to be_valid
    end

    it 'validates value if changed' do
      proxy.value = '<script>do_bad</script>'
      expect(proxy).not_to be_valid
    end
  end
end
