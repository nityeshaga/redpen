# Documents served verbatim, with their own <head>: the rail is spliced in for signed-in users.
class DocumentsController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session

  DOCUMENTS = {
    "verbatim" => <<~HTML,
      <!DOCTYPE html>
      <html><head><title>Verbatim</title></head>
      <BODY><main id="doc"><h1>A stored document</h1><p>Served byte for byte to readers.</p></main></BODY></html>
    HTML
    "bare" => "<p>A fragment with no body tag at all.</p>",
    # Two slides on one path, routed in the fragment the way a deck engine does it:
    # redraw, then history.replaceState, which fires no event.
    "deck" => <<~HTML
      <!DOCTYPE html>
      <html><head><title>Deck</title></head>
      <body style="min-height: 100vh; margin: 0"><main id="slide"></main><button id="next" style="position: fixed; left: 8px; bottom: 8px">Next</button>
      <script>
        const slides = { one: "<h1>Slide one</h1><p>The first slide of the deck says this.</p>",
                         two: "<h1>Slide two</h1><p>The second slide of the deck says that.</p>" }
        function show(name) {
          document.getElementById("slide").innerHTML = slides[name]
          history.replaceState(null, "", location.pathname + "#/" + name)
        }
        document.getElementById("next").addEventListener("click", () => show(location.hash === "#/one" ? "two" : "one"))
        show(location.hash === "#/two" ? "two" : "one")
      </script>
      </body></html>
    HTML
  }

  def show
    document = DOCUMENTS.fetch(params[:slug])
    document = helpers.redpen_inject(document) if signed_in?
    render html: document.html_safe, layout: false
  end
end
