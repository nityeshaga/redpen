module Redpen
  # A note pinned to one element of one page: "this runs long", "swap this image". The
  # page is its path and the element is a CSS selector, nothing else identifies them, so
  # the same table serves any page a host renders and the pin lands wherever the element
  # is when the page next paints. The snippet is what the element said at the time, for
  # re-anchoring and for whoever reads the note without the page in front of them.
  #
  # A page that routes in its URL fragment (a slide deck at #/tcp/4) is many pages on one
  # path, and the server never sees which. The pen does, and sends the fragment along.
  class Note < ApplicationRecord
    belongs_to :author, polymorphic: true, default: -> { Current.author }

    validates :path, :selector, :body, presence: true
    validates :path, format: { with: %r{\A/\S*\z}, message: "must be a site path" }
    validates :fragment, format: { with: /\A#\S+\z/, message: "must be a URL fragment" }, allow_blank: true
    normalizes :fragment, with: ->(fragment) { fragment.presence }

    scope :open,     -> { where(resolved_at: nil) }
    scope :resolved, -> { where.not(resolved_at: nil) }
    scope :on,       ->(path) { where(path: path) }
    scope :ordered,  -> { order(:created_at) }

    def resolve(resolution = nil)
      update!(resolved_at: Time.current, resolution: resolution.presence)
    end

    def reopen
      update!(resolved_at: nil, resolution: nil)
    end

    def resolved? = resolved_at.present?

    # Where the note was taken, as a link: the path, at the fragment if it had one.
    def location = "#{path}#{fragment}"
  end
end
