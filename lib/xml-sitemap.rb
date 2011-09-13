require 'time'
require 'date'
require 'zlib'
require 'builder'

require 'xml-sitemap/options'
require 'xml-sitemap/item'
require 'xml-sitemap/map'
require 'xml-sitemap/index'

module XmlSitemap
  class << self
    # Shortcut to XmlSitemap::Map.new
    #
    # domain  - Primary domain
    # options - Map options
    #
    def map(domain, options={})
      XmlSitemap::Map.new(domain, options) 
    end
    
    alias :new :map
    
    # Shortcut to XmlSitemap::Index.new
    #
    # options - Index options
    # 
    def index(options={})
      XmlSitemap::Index.new(options)
    end
  end
end
