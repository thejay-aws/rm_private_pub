Gem::Specification.new do |s|
  s.name        = "private_pub"
  s.version     = "1.0.3.1"
  s.author      = "Author:Ryan Bates. Customized by:Tigergm Wu"
  s.email       = "39648421@qq.com"
  s.homepage    = "http://github.com/tigergm/rm_private_pub"
  s.summary     = "Private pub/sub messaging in Rails. Customed for readmine_chat plugin"
  s.description = "Private pub/sub messaging in Rails through Faye. Customed for readmine_chat plugin"

  s.files        = Dir["{app,lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'faye'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'jasmine', '>= 1.1.1'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
