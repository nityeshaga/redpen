module Redpen
  module Generators
    # bin/rails generate redpen:views
    #
    # Copies the pen's templates into app/views/redpen/notes, where they take precedence
    # over the engine's. For colours and fonts, override the --rp-* variables instead.
    class ViewsGenerator < Rails::Generators::Base
      source_root Redpen::Engine.root.join("app/views")

      def copy_views
        directory "redpen/notes", "app/views/redpen/notes"
      end
    end
  end
end
