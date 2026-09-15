module Redpen
  # Route helpers of the host app that the engine doesn't define itself, routed through main_app.
  #
  # The engine's controllers inherit from the host's (see Redpen.parent_controller), so host
  # code such as a before_action redirecting to new_session_path runs inside the engine, where
  # route helpers resolve against the engine's routes and raise UrlGenerationError. For every
  # helper the host has and the engine doesn't, this defines a method delegating to the host's
  # routes, so that code keeps working unchanged. The pattern is Mission Control Jobs' (MIT,
  # 37signals).
  #
  # Helpers both define, like root_path, keep resolving to the engine's; use main_app.root_path.
  module HostRouteHelpers
    class << self
      def define_from(host_routes, engine_routes)
        undefine_all

        (host_routes.named_routes.helper_names - engine_routes.named_routes.helper_names).each do |name|
          define_method(name) { |*args| main_app.public_send(name, *args) }
          defined_helpers << name
        end
      end

      private
        def undefine_all
          defined_helpers.each { |name| remove_method(name) }
          defined_helpers.clear
        end

        def defined_helpers
          @defined_helpers ||= []
        end
    end
  end
end
