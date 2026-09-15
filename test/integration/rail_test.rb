require "test_helper"

# A reader's page carries nothing of the pen; a signed-in page carries the frame that
# fetches it. Verbatim documents get the rail spliced in for the signed-in reader only.
class RailTest < ActionDispatch::IntegrationTest
  test "a reader's page has no rail" do
    get page_url("about")
    assert_response :success
    assert_select "turbo-frame#redpen_notes", count: 0
    assert_select "link[rel=stylesheet][href*=redpen]", count: 0
    assert_select "script[type=module]", text: /redpen/, count: 0
  end

  test "a signed-in page has the rail pointed at its own path" do
    sign_in_as users(:nityesh)
    get page_url("about")
    assert_response :success
    assert_select "turbo-frame#redpen_notes[src=?][data-controller=redpen]", redpen.notes_path(path: "/pages/about")
    assert_select "link[rel=stylesheet][href*=redpen]"
    assert_select "script[type=module]", text: 'import "redpen"'
  end

  test "a verbatim document is served byte for byte to a reader" do
    get document_url("verbatim")
    assert_equal DocumentsController::DOCUMENTS["verbatim"], response.body
  end

  test "a verbatim document gets the rail spliced before </body> for the signed-in reader" do
    sign_in_as users(:nityesh)
    get document_url("verbatim")
    assert_response :success
    assert_select "turbo-frame#redpen_notes[src=?]", redpen.notes_path(path: "/documents/verbatim")
    assert_select "script[type=importmap]"
    assert_match(/Turbo\.session\.drive = false.*<\/body>/m, response.body)
    assert response.body.start_with?(DocumentsController::DOCUMENTS["verbatim"].split(%r{</body>}i).first), "the document precedes the rail untouched"
  end

  test "a document with no body tag gets the rail appended" do
    sign_in_as users(:nityesh)
    get document_url("bare")
    assert response.body.start_with?(DocumentsController::DOCUMENTS["bare"])
    assert_select "turbo-frame#redpen_notes[src=?]", redpen.notes_path(path: "/documents/bare")
  end

  test "the rail's assets are served by the pipeline" do
    sign_in_as users(:nityesh)
    get page_url("about")
    css = css_select("link[rel=stylesheet][href*=redpen]").first["href"]
    js  = JSON.parse(css_select("script[type=importmap]").first.text).dig("imports", "redpen")
    get css
    assert_response :success, "redpen.css at #{css}"
    assert_match(/\.redpen-pin/, response.body)
    get js
    assert_response :success, "redpen.js at #{js}"
    assert_match(/register\("redpen"/, response.body)
  end
end
