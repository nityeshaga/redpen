require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"

require "redpen/version"
require "redpen/host_route_helpers"
require "redpen/engine"

# The red pen asks the host app two questions and nothing else. Both lambdas run inside
# the engine's controller, so anything a controller can see works in them: Current.user,
# Devise's current_user, a session lookup.
module Redpen
  # Who is holding the pen. Its answer becomes every note's author and is handed to
  # `annotatable`. Nil means nobody is signed in, and the engine answers 403.
  #
  #   Redpen.author = -> { Current.user }
  #   Redpen.author = -> { current_user }        # Devise
  mattr_accessor :author, default: -> { nil }

  # May this author pen this path? Called with the page path and the author for every
  # request that reads or writes notes on that path. Default: any signed-in author, anywhere.
  #
  #   Redpen.annotatable = ->(path, author) { Community.at(path)&.administered_by?(author) }
  mattr_accessor :annotatable, default: ->(path, author) { true }

  # The engine's controllers inherit from this, so the host's own before_actions
  # (authentication, Current.session, locale) run before the pen looks at a request.
  mattr_accessor :parent_controller, default: "ApplicationController"
end
