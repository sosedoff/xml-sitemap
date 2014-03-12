module XmlSitemap
  class Item
    DEFAULT_PRIORITY = 0.5

    # ISO8601 regex from here: http://www.pelagodesign.com/blog/2009/05/20/iso-8601-date-validation-that-doesnt-suck/
    ISO8601_REGEX = /^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/

    attr_reader :target, :updated, :priority, :changefreq, :validate_time, :image_location, :image_caption, :image_geolocation, :image_title, :image_license,
                :video_thumbnail_location, :video_title, :video_description, :video_content_location, :video_player_location,
                :video_duration, :video_expiration_date, :video_rating, :video_view_count, :video_publication_date, :video_family_friendly, :video_category,
                :video_restriction, :video_gallery_location, :video_price, :video_requires_subscription, :video_uploader, :video_platform, :video_live

    def initialize(target, opts={})
      @target            = target.to_s.strip
      @updated           = opts[:updated]  || Time.now
      @priority          = opts[:priority]
      @changefreq        = opts[:period]
      @validate_time     = (opts[:validate_time] != false)

      # Refer to http://support.google.com/webmasters/bin/answer.py?hl=en&answer=178636 for requirement to support images in sitemap
      @image_location    = opts[:image_location]
      @image_caption     = opts[:image_caption]
      @image_geolocation = opts[:image_geolocation]
      @image_title       = opts[:image_title]
      @image_license     = opts[:image_license]

      # Refer to http://support.google.com/webmasters/bin/answer.py?hl=en&answer=80472&topic=10079&ctx=topic#2 for requirement to support videos in sitemap
      @video_thumbnail_location     = opts[:video_thumbnail_location]
      @video_title                  = opts[:video_title]
      @video_description            = opts[:video_description]
      @video_content_location       = opts[:video_content_location]
      @video_player_location        = opts[:video_player_location]
      @video_duration               = opts[:video_duration]
      @video_expiration_date        = opts[:video_expiration_date]
      @video_rating                 = opts[:video_rating]
      @video_view_count             = opts[:video_view_count]
      @video_publication_date       = opts[:video_publication_date]
      @video_family_friendly        = opts[:video_family_friendly]
      # tag
      @video_category               = opts[:video_category]
      @video_restriction            = opts[:video_restriction]
      @video_gallery_location       = opts[:video_gallery_location]
      @video_price                  = opts[:video_price]
      @video_requires_subscription  = opts[:video_requires_subscription]
      @video_uploader               = opts[:video_uploader]
      @video_platform               = opts[:video_platform]
      @video_live                   = opts[:video_live]

      if @changefreq
        @changefreq = @changefreq.to_sym
        unless XmlSitemap::PERIODS.include?(@changefreq)
          raise ArgumentError, "Invalid :period value '#{@changefreq}'"
        end
      end

      unless @updated.kind_of?(Time) || @updated.kind_of?(Date) || @updated.kind_of?(String)
        raise ArgumentError, "Time, Date, or ISO8601 String required for :updated!"
      end

      if @validate_time && @updated.kind_of?(String) && !(@updated =~ ISO8601_REGEX)
        raise ArgumentError, "String provided to :updated did not match ISO8601 standard!"
      end

      @updated = @updated.to_time if @updated.kind_of?(Date)

      ##############################################################################################
      ##############################################################################################

      unless @video_expiration_date.kind_of?(Time) || @video_expiration_date.kind_of?(Date) || @video_expiration_date.kind_of?(String)
        raise ArgumentError, "Time, Date, or ISO8601 String required for :video_expiration_date!" unless @video_expiration_date.nil?
      end

      if @validate_time && @video_expiration_date.kind_of?(String) && !(@video_expiration_date =~ ISO8601_REGEX)
        raise ArgumentError, "String provided to :video_expiration_date did not match ISO8601 standard!"
      end

      @video_expiration_date = @video_expiration_date.to_time if @video_expiration_date.kind_of?(Date)

      ##############################################################################################
      ##############################################################################################

      unless @video_publication_date.kind_of?(Time) || @video_publication_date.kind_of?(Date) || @video_publication_date.kind_of?(String)
        raise ArgumentError, "Time, Date, or ISO8601 String required for :video_publication_date!" unless @video_publication_date.nil?
      end

      if @validate_time && @video_publication_date.kind_of?(String) && !(@video_publication_date =~ ISO8601_REGEX)
        raise ArgumentError, "String provided to :video_publication_date did not match ISO8601 standard!"
      end

      @video_publication_date = @video_publication_date.to_time if @video_publication_date.kind_of?(Date)
    end

    # Returns the timestamp value of lastmod for renderer
    #
    def lastmod_value
      if @updated.kind_of?(Time)
        @updated.utc.iso8601
      else
        @updated.to_s
      end
    end

    # Returns the timestamp value of video:expiration_date for renderer
    #
    def video_expiration_date_value
      if @video_expiration_date.kind_of?(Time)
        @video_expiration_date.utc.iso8601
      else
        @video_expiration_date.to_s
      end
    end

    # Returns the timestamp value of video:publication_date for renderer
    #
    def video_publication_date_value
      if @video_publication_date.kind_of?(Time)
        @video_publication_date.utc.iso8601
      else
        @video_publication_date.to_s
      end
    end
  end
end
