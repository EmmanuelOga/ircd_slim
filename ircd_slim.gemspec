Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'ircd_slim'
  s.version           = '0.0.1'
  s.date              = '2011-06-05'
  s.rubyforge_project = 'ircd_slim'

  s.summary     = "ircd_slim is an small extensible IRC server."
  s.description = "ircd_slim is intended to make it easy to bridge different services to an IRC based ui."

  s.authors  = ["Emmanuel Oga"]
  s.email    = 'EmmanuelOga@gmail.com'
  s.homepage = 'http://github.com/emmanueloga'

  s.require_paths = %w[lib]

  # s.require_paths << 'ext'
  # s.extensions = %w[ext/extconf.rb]

  # s.executables = ["name"]
  # s.default_executable = 'name'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README LICENSE]

  s.add_dependency('irc_parser', [">= 0.1.2"])
  s.add_dependency('eventmachine')
  s.add_dependency('ansi')
  s.add_development_dependency('rspec', ["~> 2.0.0"])

  # = MANIFEST =
  s.files = %w[
    LICENSE
    Rakefile
    ircd_local.gemspec
    lib/ircd_local.rb
    spec/spec_helper.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.+/ }
end
