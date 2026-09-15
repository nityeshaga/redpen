module Redpen
  # Inherits from the host's controller so its before_actions run first; then asks the
  # host the two questions. Every request here is about one path, and the gate is asked
  # once, about that path. Reads are by path, never by author: two admins of one page
  # see the same notes.
  class ApplicationController < Redpen.parent_controller.constantize
    include HostRouteHelpers

    # The index answers a <turbo-frame> inside the host's page; a layout would nest one.
    layout false

    before_action :set_author, :authorize_path

    private
      def set_author
        Current.author = instance_exec(&Redpen.author)
      end

      def authorize_path
        head :forbidden unless Current.author && instance_exec(path, Current.author, &Redpen.annotatable)
      end
  end
end
