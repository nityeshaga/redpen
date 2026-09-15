module Redpen
  # Who is holding the pen this request, answered once by Redpen.author.
  class Current < ActiveSupport::CurrentAttributes
    attribute :author
  end
end
