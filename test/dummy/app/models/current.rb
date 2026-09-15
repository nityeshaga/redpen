# The host's own Current. Named the same as a real host would name it, so the engine's
# Redpen::Current is proven not to collide with it.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
