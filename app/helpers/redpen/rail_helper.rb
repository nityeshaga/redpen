module Redpen
  module RailHelper
    # The pen on a page the host lays out. One line in the layout, for whoever may pen:
    #
    #   <%= redpen_rail if signed_in? %>
    #
    # Render it as the last child of <body>: an ancestor with transform or overflow
    # would clip the pins.
    def redpen_rail(path: request.path)
      render "redpen/notes/rail", path: path
    end

    # The pen on a document the host serves verbatim, with its own <head> and no layout.
    # Splices the rail before </body>, or appends it when the document has none. From a
    # controller: `render html: helpers.redpen_inject(document).html_safe, layout: false`.
    def redpen_inject(document, path: request.path)
      rail = render("redpen/notes/standalone", path: path)
      document.match?(%r{</body>}i) ? document.sub(%r{</body>}i) { "#{rail}</body>" } : document + rail
    end
  end
end
