require "application_system_test_case"

# The only part that fails silently is the JavaScript, so this drives it: pen on, click,
# save, pin drawn, resolve, pin greys. Plus the two anchoring rules: a stale selector is
# rescued by its snippet, and a note whose element is gone lands in the orphans panel.
class PenTest < ApplicationSystemTestCase
  setup { sign_in_as users(:nityesh) }

  test "pen on, click a paragraph, save, pin, resolve" do
    visit page_path("about")
    assert_selector ".redpen-pin", count: 3

    click_button "Red pen"
    assert_selector ".redpen[data-redpen-active]"
    find("#page p.intro").click
    assert_selector ".redpen-composer[data-open]"
    assert_equal "#page > p:nth-of-type(1)", find("input[name='note[selector]']", visible: false).value
    fill_in "note[body]", with: "Cut to one sentence."
    click_button "Save"

    assert_selector ".redpen-pin", count: 4
    assert_equal "Cut to one sentence.", Redpen::Note.last.body
    assert_equal "The first paragraph of the page, which someone may want shorter.", Redpen::Note.last.snippet

    find(".redpen-pin", text: "4").click
    within(".redpen-note[data-open]") { click_button "Resolve" }
    assert_selector ".redpen-pin--resolved", count: 2
    assert Redpen::Note.last.reload.resolved?
  end

  test "a stale selector is re-anchored by its snippet; a vanished element goes to the orphans" do
    visit page_path("about")
    # The "moved" note's selector matches nothing, its snippet matches the second paragraph.
    assert_selector ".redpen-pin", count: 3
    assert_no_selector ".redpen-orphans[data-populated]"

    Redpen::Note.create!(author: users(:nityesh), path: "/pages/about", selector: "#page > blockquote:nth-of-type(1)",
                         snippet: "Text that is nowhere on this page any more.", body: "Gone.")
    visit page_path("about")
    assert_selector ".redpen-pin", count: 3
    assert_selector ".redpen-orphans[data-populated] .redpen-note", text: "Gone."
  end

  test "escape leaves pen mode; the body is a valid target" do
    visit page_path("about")
    click_button "Red pen"
    assert_selector ".redpen[data-redpen-active]"
    send_keys :escape
    assert_no_selector ".redpen[data-redpen-active]"

    click_button "Red pen"
    page.driver.browser.action.move_to_location(5, 500).click.perform
    assert_selector ".redpen-composer[data-open]"
    assert_equal "body", find("input[name='note[selector]']", visible: false).value
  end

  test "on a page that routes in its fragment, a note is taken on one slide and pinned only there" do
    visit document_path("deck")
    assert_selector "h1", text: "Slide one"
    assert_no_selector ".redpen-pin"
    assert_no_selector ".redpen-orphans[data-populated]"

    click_button "Red pen"
    find("#slide p").click
    fill_in "note[body]", with: "Open with the question."
    click_button "Save"
    assert_selector ".redpen-pin", count: 1
    assert_equal "#/one", Redpen::Note.last.fragment

    click_button "Next"
    assert_selector "h1", text: "Slide two"
    assert_selector ".redpen-pin", count: 1
    find(".redpen-pin").click
    assert_selector ".redpen-note[data-open]", text: "Say it shorter."

    click_button "Next"
    assert_selector "h1", text: "Slide one"
    assert_selector ".redpen-pin", count: 1
    assert_no_selector ".redpen-note[data-open]"
    find(".redpen-pin").click
    assert_selector ".redpen-note[data-open]", text: "Open with the question."
  end

  test "a slide drawn after the notes load still gets its pin, and the note is not lost" do
    visit document_path("deck", anchor: "/two")
    page.refresh
    assert_selector "h1", text: "Slide two"
    assert_selector ".redpen-pin", count: 1
    assert_no_selector ".redpen-orphans[data-populated]"

    page.driver.browser.manage.window.resize_to(1100, 800)
    assert_selector ".redpen-pin", count: 1
    find(".redpen-pin").click
    assert_selector ".redpen-note[data-open]", text: "Say it shorter."
  end

  test "an orphan survives being pinned again" do
    Redpen::Note.create!(author: users(:nityesh), path: "/pages/about", selector: "#page > blockquote:nth-of-type(1)",
                         snippet: "Text that is nowhere on this page any more.", body: "Gone.")
    visit page_path("about")
    assert_selector ".redpen-orphans[data-populated] .redpen-note", text: "Gone."
    page.driver.browser.manage.window.resize_to(1100, 800)
    assert_selector ".redpen-pin", count: 3
    assert_selector ".redpen-orphans[data-populated] .redpen-note", text: "Gone."
  end

  test "a fragment that names an element is a scroll position, not part of where a note is" do
    visit page_path("about", anchor: "page")
    page.refresh # from /pages/about, a visit that differs only in its fragment loads nothing
    assert_selector ".redpen-pin", count: 3
    click_button "Red pen"
    find("#page p.intro").click
    fill_in "note[body]", with: "Still the whole page."
    click_button "Save"
    assert_selector ".redpen-pin", count: 4
    assert_nil Redpen::Note.last.fragment
  end

  private
    def send_keys(*keys) = page.driver.browser.action.send_keys(*keys).perform
end
