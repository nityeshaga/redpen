// The red pen, in one module. Pulled in by the rail alone, so a page without the rail never
// asks for it. Imports Turbo because on a verbatim document the host's own entry never runs;
// on a page that already has Turbo the import map hands back the same module.
//
// The controller knows nothing about notes: it pins whatever carries a data-note-selector,
// captures a clicked element into two hidden fields, and submits a form. Everything the
// server needs travels in the form; everything the page needs to show comes back as HTML.
// Pin coordinates are never stored. They're measured from the element on every pin().
import "@hotwired/turbo-rails"
import { Application, Controller } from "@hotwired/stimulus"

class RedpenController extends Controller {
  static targets = [ "toggle", "toggleLabel", "highlight", "layer", "notes", "note", "orphans",
                     "composer", "composerTarget", "selector", "snippet", "body" ]

  connect() {
    this.hover = this.hover.bind(this)
    this.capture = this.capture.bind(this)
  }

  disconnect() {
    this.deactivate()
  }

  // ---- pins -------------------------------------------------------------------------

  pin() {
    if (!this.hasLayerTarget) return
    this.layerTarget.querySelectorAll(".redpen-pin").forEach(pin => pin.remove())
    const orphanList = this.orphansTarget.querySelector("ol")
    orphanList.replaceChildren()

    let number = 0
    for (const note of this.noteTargets) {
      const element = this.resolve(note.dataset.noteSelector, note.dataset.noteSnippet)
      note.querySelector(".redpen-note__number").textContent = ++number
      if (element) {
        this.notesTarget.appendChild(note)
        this.layerTarget.appendChild(this.pinFor(note, element, number))
      } else {
        orphanList.appendChild(note)
      }
    }
    this.orphansTarget.toggleAttribute("data-populated", orphanList.children.length > 0)
  }

  pinFor(note, element, number) {
    const pin = document.createElement("button")
    pin.type = "button"
    pin.className = "redpen-pin"
    pin.textContent = number
    pin.title = note.querySelector(".redpen-note__body").textContent
    if (note.classList.contains("redpen-note--resolved")) pin.classList.add("redpen-pin--resolved")
    const { x, y } = this.documentPoint(element.getBoundingClientRect())
    pin.style.left = `${x - 12}px`
    pin.style.top = `${y - 12}px`
    pin.addEventListener("click", event => { event.stopPropagation(); this.open(note, pin) })
    return pin
  }

  // The selector first. When the page has been rewritten under the note, the snippet:
  // the same kind of element whose text still starts the way it did.
  resolve(selector, snippet) {
    try { const element = document.querySelector(selector); if (element) return element } catch {}
    if (!snippet || snippet.length < 12) return null
    const tag = selector.split(">").pop().trim().split(":")[0]
    const candidates = document.querySelectorAll(tag.startsWith("#") ? "*" : tag)
    let match = null
    for (const element of candidates) {
      if (element.closest(".redpen") || !this.textOf(element).startsWith(snippet)) continue
      if (!match || element.textContent.length < match.textContent.length) match = element
    }
    return match
  }

  open(note, anchor) {
    this.close()
    const rect = anchor.getBoundingClientRect()
    this.place(note, rect.right + 8, rect.top)
  }

  // ---- pen mode ---------------------------------------------------------------------

  toggle() {
    this.element.hasAttribute("data-redpen-active") ? this.deactivate() : this.activate()
  }

  activate() {
    this.close()
    this.element.setAttribute("data-redpen-active", "")
    this.toggleLabelTarget.textContent = "Click an element"
    document.addEventListener("pointermove", this.hover, true)
    document.addEventListener("click", this.capture, true)
  }

  deactivate() {
    this.element.removeAttribute("data-redpen-active")
    if (this.hasToggleLabelTarget) this.toggleLabelTarget.textContent = "Red pen"
    if (this.hasHighlightTarget) this.highlightTarget.removeAttribute("data-visible")
    document.removeEventListener("pointermove", this.hover, true)
    document.removeEventListener("click", this.capture, true)
  }

  hover(event) {
    const element = this.targetOf(event)
    if (!element) { this.highlightTarget.removeAttribute("data-visible"); return }
    const rect = element.getBoundingClientRect()
    Object.assign(this.highlightTarget.style, {
      left: `${rect.left}px`, top: `${rect.top}px`, width: `${rect.width}px`, height: `${rect.height}px`
    })
    this.highlightTarget.setAttribute("data-visible", "")
  }

  capture(event) {
    const element = this.targetOf(event)
    if (!element) return
    event.preventDefault()
    event.stopPropagation()
    this.deactivate()

    const snippet = this.textOf(element).slice(0, 120)
    this.selectorTarget.value = this.cssPath(element)
    this.snippetTarget.value = snippet
    this.composerTargetTarget.textContent = snippet || `<${element.tagName.toLowerCase()}>`
    this.bodyTarget.value = ""
    this.place(this.composerTarget, event.clientX + 12, event.clientY + 12)
    this.bodyTarget.focus()
  }

  // The page's own elements only, never our UI. The body counts: a note on the body is
  // a note on the whole page ("add a testimonials section").
  targetOf(event) {
    const element = event.target
    if (!(element instanceof Element)) return null
    if (element.closest(".redpen")) return null
    if (element === document.documentElement) return null
    return element
  }

  submit(event) {
    event.preventDefault()
    this.composerTarget.requestSubmit()
  }

  close() {
    for (const open of this.element.querySelectorAll("[data-open]")) open.removeAttribute("data-open")
  }

  stop(event) {
    event.stopPropagation()
  }

  keydown(event) {
    if (event.key === "Escape") { this.deactivate(); this.close() }
  }

  // ---- geometry ---------------------------------------------------------------------

  // Viewport point → coordinates inside the layer, whatever positions the layer.
  documentPoint({ left, top }) {
    const origin = this.layerTarget.getBoundingClientRect()
    return { x: left - origin.left, y: top - origin.top }
  }

  place(box, clientX, clientY) {
    box.setAttribute("data-open", "")
    const width = box.offsetWidth, height = box.offsetHeight
    const clientLeft = Math.max(8, Math.min(clientX, window.innerWidth - width - 8))
    const clientTop = Math.max(8, Math.min(clientY, window.innerHeight - height - 8))
    const { x, y } = this.documentPoint({ left: clientLeft, top: clientTop })
    box.style.left = `${x}px`
    box.style.top = `${y}px`
  }

  // ---- text and selector ------------------------------------------------------------

  textOf(element) {
    return (element.textContent || "").replace(/\s+/g, " ").trim()
  }

  // Up from the element to the nearest id, or to the body. An id short-circuits the
  // chain, which is what lets a pin survive a rewrite of everything around it.
  cssPath(element) {
    const parts = []
    let node = element
    while (node && node.nodeType === 1 && node !== document.body && node !== document.documentElement) {
      if (node.id) { parts.unshift(`#${CSS.escape(node.id)}`); break }
      const siblings = Array.from(node.parentNode?.children || []).filter(sibling => sibling.tagName === node.tagName)
      const index = siblings.indexOf(node) + 1
      parts.unshift(`${node.tagName.toLowerCase()}:nth-of-type(${index})`)
      node = node.parentNode
    }
    if (!parts.length || !parts[0].startsWith("#")) parts.unshift("body")
    return parts.join(" > ")
  }
}

// The pen's own Stimulus application. A host's application, if any, ignores the
// "redpen" identifier the way this one ignores the host's.
Application.start().register("redpen", RedpenController)
