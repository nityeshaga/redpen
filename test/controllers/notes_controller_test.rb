require "test_helper"

class Redpen::NotesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:nityesh) }

  test "signed out, the host's own sign-in redirect fires, naming a host route" do
    delete "/session"
    get redpen.notes_url(path: "/pages/about")
    assert_redirected_to "/session/new"
  end

  test "the host's route helpers are delegated; the engine's own are not" do
    assert_includes Redpen::HostRouteHelpers.instance_methods, :new_session_path
    assert_includes Redpen::HostRouteHelpers.instance_methods, :page_path
    assert_not_includes Redpen::HostRouteHelpers.instance_methods, :notes_path
  end

  test "no author, nothing served" do
    Redpen.author = -> { nil }
    get redpen.notes_url(path: "/pages/about")
    assert_response :forbidden
  ensure
    Redpen.author = -> { Current.user }
  end

  test "a path the host says is off limits is off limits" do
    get redpen.notes_url(path: "/pages/private")
    assert_response :forbidden
    assert_no_difference -> { Redpen::Note.count } do
      post redpen.notes_url, params: { note: { path: "/pages/private", selector: "body", body: "x" } }
    end
    assert_response :forbidden
  end

  test "index renders one page's notes inside the frame, with no layout, whoever wrote them" do
    get redpen.notes_url(path: "/pages/about")
    assert_response :success
    assert_select "script[type=importmap]", count: 0, message: "the host layout must not wrap the frame"
    assert_select "turbo-frame#redpen_notes"
    assert_select "li.redpen-note", count: 3
    assert_select "li[data-note-selector='#{redpen_notes(:intro).selector}'][data-note-snippet='#{redpen_notes(:intro).snippet}']"
    assert_select "li.redpen-note--resolved", text: /Bumped to 48px/
    assert_select "form.redpen-composer input[name='note[path]'][value='/pages/about']"
    assert_select "form[action=?]", redpen.note_resolution_path(redpen_notes(:intro))
  end

  test "create stores the note under the pen holder and repaints the rail for that page" do
    assert_difference -> { Redpen::Note.count }, 1 do
      post redpen.notes_url, params: { note: { path: "/pages/about", selector: "#page > h1", snippet: "Page about", body: "Bigger." } }
    end
    assert_redirected_to redpen.notes_url(path: "/pages/about")
    assert_equal users(:nityesh), Redpen::Note.last.author
  end

  test "an invalid note is a bug in our own form, so it raises rather than vanishing" do
    assert_no_difference -> { Redpen::Note.count } do
      post redpen.notes_url, params: { note: { path: "/pages/about", selector: "#page > h1", body: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "destroy removes the note, even another author's" do
    assert_difference -> { Redpen::Note.count }, -1 do
      delete redpen.note_url(redpen_notes(:headline))
    end
    assert_redirected_to redpen.notes_url(path: "/pages/about")
  end

  test "resolve and reopen are create and destroy on the resolution" do
    note = redpen_notes(:intro)
    post redpen.note_resolution_url(note), params: { resolution: "Done." }
    assert_redirected_to redpen.notes_url(path: "/pages/about")
    assert note.reload.resolved?
    assert_equal "Done.", note.resolution

    delete redpen.note_resolution_url(note)
    assert_not note.reload.resolved?
  end

  test "resolving a note on an off-limits path is refused" do
    post redpen.note_resolution_url(redpen_notes(:private)), params: { resolution: "Sneaky." }
    assert_response :forbidden
    assert_not redpen_notes(:private).reload.resolved?
  end
end
