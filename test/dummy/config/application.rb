require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Whichever asset pipeline the Gemfile chose, plus the gem under test.
Bundler.require(*Rails.groups)
require "redpen"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
