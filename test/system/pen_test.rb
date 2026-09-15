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

  private
    def send_keys(*keys) = page.driver.browser.action.send_keys(*keys).perform
end
