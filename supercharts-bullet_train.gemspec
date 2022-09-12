require_relative "lib/bullet_train/supercharts/version"

Gem::Specification.new do |spec|
  spec.name = "supercharts-bullet_train"
  spec.version = BulletTrain::Supercharts::VERSION
  spec.authors = ["Pascal Laliberté"]
  spec.email = ["pascal@hey.com"]
  spec.homepage = "https://github.com/supercharts-dev/supercharts-bullet_train"
  spec.summary = "Supercharts for Bullet Train"
  spec.description = spec.summary
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "groupdate"
end
