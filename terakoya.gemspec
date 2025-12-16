require_relative "lib/terakoya/version"

Gem::Specification.new do |spec|
  spec.name        = "terakoya"
  spec.version     = Terakoya::VERSION
  spec.authors     = ["MOAB"]
  spec.email       = ["hello@moab.jp"]
  spec.homepage    = "https://github.com/moab-jp/terakoya"
  spec.summary     = "Project-based learning platform for Rails 8"
  spec.description = "A drop-in Rails engine for student-directed, project-based learning with English immersion support."
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moab-jp/terakoya"
  spec.metadata["changelog_uri"] = "https://github.com/moab-jp/terakoya/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "propshaft"
end
