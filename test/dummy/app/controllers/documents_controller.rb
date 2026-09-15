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
    "bare" => "<p>A fragment with no body tag at all.</p>"
  }

  def show
    document = DOCUMENTS.fetch(params[:slug])
    document = helpers.redpen_inject(document) if signed_in?
    render html: document.html_safe, layout: false
  end
end
