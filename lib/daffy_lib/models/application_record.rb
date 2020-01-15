# frozen_string_literal: true

require 'active_record'

class DaffyLib::ApplicationRecord < ActiveRecord::Base
  include DaffyLib::HasGuid

  self.abstract_class = true
end
