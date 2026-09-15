require_relative "lib/redpen/version"

Gem::Specification.new do |spec|
  spec.name        = "redpen-rails"
  spec.version     = Redpen::VERSION
  spec.authors     = [ "Nityesh Agarwal", "Luo Ji" ]
  spec.email       = [ "nityeshagarwal@gmail.com" ]
  spec.homepage    = "https://github.com/nityeshaga/redpen"
  spec.summary     = "Click any element of a page, leave a note. The feedback layer for AI-made pages."
  spec.description = "A Rails engine that lets a signed-in person pin notes to elements of any page: " \
                     "where on the page, what was there, what should change. Notes are read back by " \
                     "the host app (or its agent), resolved with one line, and the line shows up on the page."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "CHANGELOG.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "importmap-rails", ">= 2.0"
  spec.add_dependency "turbo-rails", ">= 2.0"
  spec.add_dependency "stimulus-rails", ">= 1.3"
end
