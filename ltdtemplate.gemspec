Gem::Specification.new do |s|
  s.name         = "ltdtemplate"
  s.version      = "0.2.1"
  s.date         = "2013-07-28"
  s.authors      = ["Brian Katzung"]
  s.email        = ["briank@kappacs.com"]
  s.homepage     = "http://rubygems.org/gems/ltdtemplate"
  s.summary      = "A resource-limitable, textual templating system"
  s.description  = "A resource-limitable, user-editable, textual templating system"
  s.license      = "MIT"
 
  s.files        = Dir.glob("lib/**/*") +
      %w{ltdtemplate.gemspec Gemfile .yardopts HISTORY.txt RESOURCES.txt
      TEMPLATE_MANUAL.html}
  s.test_files   = Dir.glob("test/**/[0-9]*.rb")
  s.require_path = 'lib'
end
