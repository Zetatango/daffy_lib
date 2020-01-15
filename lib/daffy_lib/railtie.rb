# frozen_string_literal: true

require 'daffy_lib'
require 'rails'

# :nocov:
class DaffyLib::Railtie < Rails::Railtie
  rake_tasks do
    load 'tasks/db_tasks.rake'
  end
end
# :nocov:
