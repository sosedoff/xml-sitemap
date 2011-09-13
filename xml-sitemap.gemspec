require File.expand_path('../lib/xml-sitemap/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "xml-sitemap"
  s.version     = XmlSitemap::VERSION.dup
  s.summary     = "Simple XML sitemap generator for Ruby/Rails applications."
  s.description = "Provides a wrapper to generate XML sitemaps and sitemap indexes."
  s.homepage    = "http://github.com/sosedoff/xml-sitemap"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake',      '~> 0.8'
  s.add_development_dependency 'rspec',     '~> 2.6'
  s.add_development_dependency 'simplecov', '~> 0.4'
  
  s.add_runtime_dependency      'builder',  '>= 2.0'
  s.add_runtime_dependency      'nokogiri', '~> 1.5.0'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end