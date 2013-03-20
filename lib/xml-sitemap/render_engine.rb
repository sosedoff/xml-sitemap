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

              if item.image_location
                u["image"].image do |a|
                  a["image"].loc                 item.image_location
                  a["image"].caption             item.image_caption     if item.image_caption
                  a["image"].title               item.image_title       if item.image_title
                  a["image"].license             item.image_license     if item.image_license
                  a["image"].geo_location        item.image_geolocation if item.image_geolocation
                end
              end

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
    def render_builder
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
      xml.urlset(XmlSitemap::MAP_SCHEMA_OPTIONS) { |s|
        @items.each do |item|
          s.url do |u|
            u.loc        item.target

            if item.image_location
              u.image :image do |a|
                a.tag!("image:loc")           {|b| b.text! item.image_location}
                a.tag!("image:caption")       {|b| b.text! item.image_caption}        if item.image_caption
                a.tag!("image:title")         {|b| b.text! item.image_title}          if item.image_title
                a.tag!("image:license")       {|b| b.text! item.image_license}        if item.image_license
                a.tag!("image:geo_location")  {|b| b.text! item.image_geolocation}    if item.image_geolocation
              end
            end

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

        # Format and image tag specifications found in http://support.google.com/webmasters/bin/answer.py?hl=en&answer=178636
        if item.image_location
          item_string += "    <image:image>\n"
          item_string += "      <image:loc>#{CGI::escapeHTML(item.image_location)}</image:loc>\n"
          item_string += "      <image:caption>#{CGI::escapeHTML(item.image_caption)}</image:caption>\n"               if item.image_caption
          item_string += "      <image:title>#{CGI::escapeHTML(item.image_title)}</image:title>\n"                     if item.image_title
          item_string += "      <image:license>#{CGI::escapeHTML(item.image_license)}</image:license>\n"               if item.image_license
          item_string += "      <image:geo_location>#{CGI::escapeHTML(item.image_geolocation)}</image:geo_location>\n" if item.image_geolocation
          item_string += "    </image:image>\n"
        end

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
