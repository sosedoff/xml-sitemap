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

              # Format and image tag specifications found at http://support.google.com/webmasters/bin/answer.py?hl=en&answer=178636
              if item.image_location
                u["image"].image do |a|
                  a["image"].loc                item.image_location
                  a["image"].caption            item.image_caption     if item.image_caption
                  a["image"].title              item.image_title       if item.image_title
                  a["image"].license            item.image_license     if item.image_license
                  a["image"].geo_location       item.image_geolocation if item.image_geolocation
                end
              end

              # Format and video tag specifications found at http://support.google.com/webmasters/bin/answer.py?hl=en&answer=80472&topic=10079&ctx=topic#2
              if item.video_thumbnail_location && item.video_title && item.video_description && (item.video_content_location || item.video_player_location)
                u["video"].video do |a|
                  a["video"].thumbnail_loc            item.video_thumbnail_location
                  a["video"].title                    item.video_title
                  a["video"].description              item.video_description
                  a["video"].content_loc              item.video_content_location                       if item.video_content_location
                  a["video"].player_loc               item.video_player_location                        if item.video_player_location
                  a["video"].duration                 item.video_duration.to_s                          if item.video_duration
                  a["video"].expiration_date          item.video_expiration_date_value                  if item.video_expiration_date
                  a["video"].rating                   item.video_rating.to_s                            if item.video_rating
                  a["video"].view_count               item.video_view_count.to_s                        if item.video_view_count
                  a["video"].publication_date         item.video_publication_date_value                 if item.video_publication_date
                  a["video"].family_friendly          item.video_family_friendly                        if item.video_family_friendly
                  a["video"].category                 item.video_category                               if item.video_category
                  a["video"].restriction              item.video_restriction, :relationship => "allow"  if item.video_restriction
                  a["video"].gallery_loc              item.video_gallery_location                       if item.video_gallery_location
                  a["video"].price                    item.video_price.to_s, :currency => "USD"         if item.video_price
                  a["video"].requires_subscription    item.video_requires_subscription                  if item.video_requires_subscription
                  a["video"].uploader                 item.video_uploader                               if item.video_uploader
                  a["video"].platform                 item.video_platform, :relationship => "allow"     if item.video_platform
                  a["video"].live                     item.video_live                                   if item.video_live
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
                a.tag!("image:loc")           { |b| b.text! item.image_location }
                a.tag!("image:caption")       { |b| b.text! item.image_caption }        if item.image_caption
                a.tag!("image:title")         { |b| b.text! item.image_title }          if item.image_title
                a.tag!("image:license")       { |b| b.text! item.image_license }        if item.image_license
                a.tag!("image:geo_location")  { |b| b.text! item.image_geolocation }    if item.image_geolocation
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
        result << ' ' + key + '="' + val + '"'
      end

      result << ">\n"

      item_results = []
      @items.each do |item|
        item_string  = "  <url>\n"
        item_string << "    <loc>#{CGI::escapeHTML(item.target)}</loc>\n"

        # Format and image tag specifications found at http://support.google.com/webmasters/bin/answer.py?hl=en&answer=178636
        if item.image_location
          item_string << "    <image:image>\n"
          item_string << "      <image:loc>#{CGI::escapeHTML(item.image_location)}</image:loc>\n"
          item_string << "      <image:caption>#{CGI::escapeHTML(item.image_caption)}</image:caption>\n"               if item.image_caption
          item_string << "      <image:title>#{CGI::escapeHTML(item.image_title)}</image:title>\n"                     if item.image_title
          item_string << "      <image:license>#{CGI::escapeHTML(item.image_license)}</image:license>\n"               if item.image_license
          item_string << "      <image:geo_location>#{CGI::escapeHTML(item.image_geolocation)}</image:geo_location>\n" if item.image_geolocation
          item_string << "    </image:image>\n"
        end

        # Format and video tag specifications found at http://support.google.com/webmasters/bin/answer.py?hl=en&answer=80472&topic=10079&ctx=topic#2
        if item.video_thumbnail_location && item.video_title && item.video_description && (item.video_content_location || item.video_player_location)
          item_string << "    <video:video>\n"
          item_string << "      <video:thumbnail_loc>#{CGI::escapeHTML(item.video_thumbnail_location)}</video:thumbnail_loc>\n"
          item_string << "      <video:title>#{CGI::escapeHTML(item.video_title)}</video:title>\n"
          item_string << "      <video:description>#{CGI::escapeHTML(item.video_description)}</video:description>\n"
          item_string << "      <video:content_loc>#{CGI::escapeHTML(item.video_content_location)}</video:content_loc>\n"                           if item.video_content_location
          item_string << "      <video:player_loc>#{CGI::escapeHTML(item.video_player_location)}</video:player_loc>\n"                              if item.video_player_location
          item_string << "      <video:duration>#{CGI::escapeHTML(item.video_duration.to_s)}</video:duration>\n"                                    if item.video_duration
          item_string << "      <video:expiration_date>#{item.video_expiration_date_value}</video:expiration_date>\n"                               if item.video_expiration_date
          item_string << "      <video:rating>#{CGI::escapeHTML(item.video_rating.to_s)}</video:rating>\n"                                          if item.video_rating
          item_string << "      <video:view_count>#{CGI::escapeHTML(item.video_view_count.to_s)}</video:view_count>\n"                              if item.video_view_count
          item_string << "      <video:publication_date>#{item.video_publication_date_value}</video:publication_date>\n"                            if item.video_publication_date
          item_string << "      <video:family_friendly>#{CGI::escapeHTML(item.video_family_friendly)}</video:family_friendly>\n"                    if item.video_family_friendly
          item_string << "      <video:category>#{CGI::escapeHTML(item.video_category)}</video:category>\n"                                         if item.video_category
          item_string << "      <video:restriction relationship=\"allow\">#{CGI::escapeHTML(item.video_restriction)}</video:restriction>\n"         if item.video_restriction
          item_string << "      <video:gallery_loc>#{CGI::escapeHTML(item.video_gallery_location)}</video:gallery_loc>\n"                           if item.video_gallery_location
          item_string << "      <video:price currency=\"USD\">#{CGI::escapeHTML(item.video_price.to_s)}</video:price>\n"                            if item.video_price
          item_string << "      <video:requires_subscription>#{CGI::escapeHTML(item.video_requires_subscription)}</video:requires_subscription>\n"  if item.video_requires_subscription
          item_string << "      <video:uploader>#{CGI::escapeHTML(item.video_uploader)}</video:uploader>\n"                                         if item.video_uploader
          item_string << "      <video:platform relationship=\"allow\">#{CGI::escapeHTML(item.video_platform)}</video:platform>\n"                  if item.video_platform
          item_string << "      <video:live>#{CGI::escapeHTML(item.video_live)}</video:live>\n"                                                     if item.video_live
          item_string << "    </video:video>\n"
        end

        item_string << "    <lastmod>#{item.lastmod_value}</lastmod>\n"
        item_string << "    <changefreq>#{item.changefreq}</changefreq>\n"
        item_string << "    <priority>#{item.priority}</priority>\n"
        item_string << "  </url>\n"

        item_results << item_string
      end

      result << item_results.join("")
      result << "</urlset>\n"

      result
    end
  end
end
