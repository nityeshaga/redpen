module Redpen
  module Generators
    # bin/rails generate redpen:install
    #
    # Migration, initializer, mount line. Idempotent: run it twice and nothing doubles.
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_migrations
        rake "redpen:install:migrations"
      end

      def create_initializer
        template "initializer.rb", "config/initializers/redpen.rb"
      end

      def mount_engine
        route 'mount Redpen::Engine, at: "/redpen"' unless File.read("config/routes.rb").include?("Redpen::Engine")
      end

      def show_next_steps
        say <<~MSG

          Red pen is installed. Three things left:

            1. bin/rails db:migrate
            2. Open config/initializers/redpen.rb and say who holds the pen.
            3. Put <%= redpen_rail if signed_in? %> as the last line of <body> in your layout.

        MSG
      end
    end
  end
end
