Gem::Specification.new do |s|
  s.name         = "ltdtemplate"
  s.version      = "0.1.3"
  s.date         = "2013-07-13"
  s.authors      = ["Brian Katzung"]
  s.email        = ["briank@kappacs.com"]
  s.homepage     = "http://rubygems.org/gems/ltdtemplate"
  s.summary      = "A template system with limitable resource usage"
  s.description  = "A template system with limitable resource usage, e.g. for administrator-editable message localization"
  s.license      = "MIT"
 
  s.files        = Dir.glob("lib/**/*") +
      %w{ltdtemplate.gemspec Gemfile .yardopts HISTORY.txt TEMPLATE_MANUAL.html}
  s.test_files   = Dir.glob("test/**/[0-9]*.rb")
  s.require_path = 'lib'
end
