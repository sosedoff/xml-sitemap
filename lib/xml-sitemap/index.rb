module XmlSitemap
  class Index
    attr_reader :domain, :maps
    
    def initialize(domain)
      @domain = domain
      @maps   = []
    end
    
    # Add XmlSitemap::Map item to sitemap index
    def add(map)
      raise 'XmlSitemap::Map object requred!' unless map.kind_of?(Map)
      @maps << {:loc => "http://#{@domain}/#{map.index_path}", :lastmod => map.created_at.utc.iso8601}
    end
    
    # Generate sitemap XML index
    def render
      output = [] ; map_id = 1
      output << '<?xml version="1.0" encoding="UTF-8"?>'
      output << '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
      @maps.each do |m|
        output << '<sitemap>'
        output << "<loc>#{m[:loc]}</loc>"
        output << "<lastmod>#{m[:lastmod]}</lastmod>"
        output << '</sitemap>'
      end
      output << '</sitemapindex>'
      return output.join("\n")
    end
  end
end
