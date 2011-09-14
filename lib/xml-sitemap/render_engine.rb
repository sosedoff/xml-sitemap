module XmlSitemap
  module RenderEngine
    private
    
    # Render with Nokogiri gem
    #
    def render_nokogiri
      unless defined? Nokogiri
        raise ArgumentError, "Nokogiri not found!"
      end
      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
        xml.urlset(XmlSitemap::MAP_SCHEMA_OPTIONS) { |s|
          @items.each do |item|
            s.url do |u|
              u.loc        item.target
              u.lastmod    item.lastmod_value
              u.changefreq item.changefreq.to_s
              u.priority   item.priority.to_s
            end
          end
        }
      end
      builder.to_xml
    end
    
    # Render with Builder gem
    #
    def render_bulder
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
      xml.urlset(XmlSitemap::MAP_SCHEMA_OPTIONS) { |s|
        @items.each do |item|
          s.url do |u|
            u.loc        item.target
            u.lastmod    item.lastmod_value
            u.changefreq item.changefreq.to_s
            u.priority   item.priority.to_s
          end
        end
      }.to_s
    end
    
    # Render with plain strings
    #
    def render_string
      result = '<?xml version="1.0" encoding="UTF-8"?>' + "\n<urlset"
        
      XmlSitemap::MAP_SCHEMA_OPTIONS.each do |key, val|
        result += ' ' + key + '="' + val + '"'
      end
      
      result += ">\n"
      
      item_results = []
      @items.each do |item|
        item_string  = "  <url>\n"
        item_string += "    <loc>#{CGI::escapeHTML(item.target)}</loc>\n"
        item_string += "    <lastmod>#{item.lastmod_value}</lastmod>\n"
        item_string += "    <changefreq>#{item.changefreq}</changefreq>\n"
        item_string += "    <priority>#{item.priority}</priority>\n"
        item_string += "  </url>\n"
        
        item_results << item_string
      end
      
      result = result + item_results.join("") + "</urlset>\n"
      result
    end
  end
end
