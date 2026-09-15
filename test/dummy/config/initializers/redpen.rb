Redpen.author = -> { Current.user }
# Anyone signed in may pen anything except the private pages.
Redpen.annotatable = ->(path, author) { !path.start_with?("/pages/private") }
