module Redpen
  class Engine < ::Rails::Engine
    isolate_namespace Redpen

    # One prebuilt module and one stylesheet. Sprockets needs telling; Propshaft
    # already serves everything on its paths.
    initializer "redpen.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[ redpen.js redpen.css ]
      end
    end

    # `pin "redpen"` lands in the host's import map without the host editing anything.
    initializer "redpen.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
      end
    end

    # `redpen_rail` and `redpen_inject` in every host view and controller.
    initializer "redpen.helpers" do
      ActiveSupport.on_load(:action_controller_base) { helper Redpen::RailHelper }
    end
  end
end
