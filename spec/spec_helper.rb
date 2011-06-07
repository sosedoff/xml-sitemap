$:.unshift File.expand_path("../..", __FILE__)

require 'simplecov'
SimpleCov.start do
  add_group 'XmlSitemap', 'lib/xml-sitemap'
end

require 'xml-sitemap'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end
