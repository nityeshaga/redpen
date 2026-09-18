# Changelog

## 0.1.2 — 2026-09-18

**Security.** `NotesController` asked `Redpen.annotatable` about `params[:path]` whenever the query named one, while `create` wrote the note to `note[path]` and `destroy` removed whatever note the id named. A signed-in author allowed on any one page could therefore add a note to, or delete a note from, a page they may not pen, by naming their own page in the query. The gate now asks about the page the request actually touches: the query's path for the index, the note's own path for create and destroy. Resolving and reopening were never affected. Found reviewing Curated Connections' landing pages.

## 0.1.1 — 2026-09-16

Helpers register in `to_prepare` instead of an engine initializer. A host that loads `ActionController::Base` during boot (Curated Connections requires a lib from `application.rb` that does) fired the `on_load` hook before the autoloader existed, and `Redpen::RailHelper` failed to resolve. Found on the first day of the second host.

## 0.1.0 — 2026-09-16

First extraction, from nityesh.com. Notes pinned to elements by path + CSS selector, a pen UI as one Stimulus controller, resolve/reopen as a resolution resource, `redpen_rail` and `redpen_inject` helpers, `redpen:install` and `redpen:views` generators. Sprockets and Propshaft, import maps only.
