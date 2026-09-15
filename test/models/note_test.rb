require "test_helper"

class Redpen::NoteTest < ActiveSupport::TestCase
  test "resolving stamps the time and keeps the line; reopening clears both" do
    note = redpen_notes(:intro)
    note.resolve("Trimmed it.")
    assert note.resolved?
    assert_equal "Trimmed it.", note.resolution

    note.reopen
    assert_not note.resolved?
    assert_nil note.resolution
  end

  test "open and resolved are the two halves of the table" do
    assert_equal Redpen::Note.count, Redpen::Note.open.count + Redpen::Note.resolved.count
    assert_includes Redpen::Note.resolved, redpen_notes(:headline)
    assert_includes Redpen::Note.open, redpen_notes(:intro)
  end

  test "a note needs a page, an element and a body" do
    note = Redpen::Note.new(author: users(:nityesh))
    assert_not note.valid?
    assert note.errors[:path].any? && note.errors[:selector].any? && note.errors[:body].any?

    note.assign_attributes(path: "about", selector: "p", body: "x")
    assert_not note.valid?, "a path must start at the site root"
  end

  test "the author defaults to whoever holds the pen" do
    Redpen::Current.author = users(:piyush)
    note = Redpen::Note.create!(path: "/pages/about", selector: "body", body: "Page-level.")
    assert_equal users(:piyush), note.author
  ensure
    Redpen::Current.reset
  end

  test "the host's Current and the engine's do not collide" do
    Current.user = users(:nityesh)
    Redpen::Current.author = users(:piyush)
    assert_equal users(:nityesh), Current.user
    assert_equal users(:piyush), Redpen::Current.author
  ensure
    Current.reset
    Redpen::Current.reset
  end
end
