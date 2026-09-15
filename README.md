# Red pen

Click any element of a page, say what should change. The feedback layer for AI-made pages, as a Rails engine.

A note is not a chat message. It carries **where** on the page (the path and a CSS selector), **what was there** (a text snippet), and **what should change** (the note). That is exactly what a model, or a person, needs to make a surgical edit without seeing the page. The host app reads open notes, does the work, and resolves each with one line that shows up under the note on the page.

The gem captures. The app decides. No auth, no AI, no page model.

## Install

```ruby
# Gemfile
gem "redpen-rails"
```

```sh
bin/rails generate redpen:install   # migration, initializer, mount line
bin/rails db:migrate
```

```ruby
# config/initializers/redpen.rb
Redpen.author = -> { Current.user }                      # or current_user with Devise
Redpen.annotatable = ->(path, author) { true }           # who may pen which path
```

```erb
<%# app/views/layouts/application.html.erb, last child of <body> %>
<%= redpen_rail if signed_in? %>
```

That's the install. Signed in, every page has a "Red pen" pill bottom-right. Click it, click an element, type, save. A numbered pin lands on the element. Click a pin to read the note, resolve it, reopen it, or delete it. Readers get nothing: no markup, no stylesheet, no JavaScript.

## The two questions

Both lambdas run inside the engine's controller, so anything a controller can see works in them.

| | Asked | Default |
|---|---|---|
| `Redpen.author` | Who is holding the pen? Becomes every note's author. Nil means 403. | `-> { nil }` |
| `Redpen.annotatable` | May this author pen this path? Asked once per request, about that path. | `->(path, author) { true }` |

Notes are read **by path**, not by author. Two admins of one page see the same notes; the author column is attribution.

`Redpen.parent_controller` (default `"ApplicationController"`) is what the engine's controllers inherit from, so your authentication runs first.

## Reading notes back

```ruby
Redpen::Note.open.on("/communities/42/")   # path, selector, snippet, body
note.resolve("Cut the headline to six words.")
note.reopen
```

If the host has an agent or an MCP server, it writes its own tool over these two verbs. Scope it through whatever owns the page, never `Redpen::Note.all`: in a multi-tenant app that would hand one tenant every other tenant's notes.

## Documents served verbatim

For a page with its own `<head>` and no layout, splice the rail in at serve time:

```ruby
render html: helpers.redpen_inject(document).html_safe, layout: false
```

## Restyling

Every colour and font is a CSS variable (`--rp-paper`, `--rp-red`, `--rp-mono`, …) on `:root`; override them after `redpen.css`. For deeper changes, `bin/rails generate redpen:views` copies the templates into `app/views/redpen/notes`, where they take precedence.

## Pins that survive rewrites

A pin follows its selector, and the selector short-circuits at the nearest ancestor with an `id`. If a generator stamps ids on block elements and preserves them on revision, pins survive a full rewrite. When a selector no longer matches, the snippet re-anchors the note to the same kind of element whose text still starts the same way. When nothing matches, the note lands in an "Element gone" panel with its snippet, still readable and resolvable.

## Requirements and non-goals

Rails 8.0+, import maps (importmap-rails), Turbo and Stimulus. Sprockets and Propshaft both work. Not in v1: esbuild/webpack hosts, threads on notes, visitor comments, generating or hosting pages.

## Development

```sh
bundle install
bin/rails db:migrate
bin/rails test                                          # models, controllers, integration
bin/rails test test/system                              # a headless Chrome clicks the pen
BUNDLE_GEMFILE=gemfiles/sprockets.gemfile bin/rails test
```

## License

MIT. Extracted from [nityesh.com](https://nityesh.com), first hosted for real by [Curated Connections](https://curatedconnections.io).
