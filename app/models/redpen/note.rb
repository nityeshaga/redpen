module Redpen
  # A note pinned to one element of one page: "this runs long", "swap this image". The
  # page is its path and the element is a CSS selector, nothing else identifies them, so
  # the same table serves any page a host renders and the pin lands wherever the element
  # is when the page next paints. The snippet is what the element said at the time, for
  # re-anchoring and for whoever reads the note without the page in front of them.
  class Note < ApplicationRecord
    belongs_to :author, polymorphic: true, default: -> { Current.author }

    validates :path, :selector, :body, presence: true
    validates :path, format: { with: %r{\A/\S*\z}, message: "must be a site path" }

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
  end
end
