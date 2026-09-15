source "https://rubygems.org"

# The gem's own dependencies live in redpen-rails.gemspec.
gemspec

# The dummy host app the tests run inside. Propshaft here; gemfiles/sprockets.gemfile is the other pipeline.
gem "puma"
gem "sqlite3", ">= 2.1"
gem "propshaft"

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

# json 3.0 dropped the positional options hash Active Support 8.1 still passes.
gem "json", "< 3"
