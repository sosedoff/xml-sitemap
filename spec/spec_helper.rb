$:.unshift File.expand_path("../..", __FILE__)

require 'simplecov'
SimpleCov.start do
  add_group 'XmlSitemap', 'lib/xml-sitemap'
end

require 'digest'
require 'xml-sitemap'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def checksum(content)
  Digest::SHA1.hexdigest(content)
end

def gunzip(path)
  contents = nil
  File.open(path) do |f|
    gz = Zlib::GzipReader.new(f)
    contents = gz.read
    gz.close
  end
  contents
end

module FileHelper
  def delete_if_exists(path)
    File.delete(path) if File.exists?(path)
  end
end

class File
  extend FileHelper
end