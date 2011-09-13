module XmlSitemap
  class Item
    DEFAULT_PRIORITY = 0.5

    # ISO8601 regex from here: http://www.pelagodesign.com/blog/2009/05/20/iso-8601-date-validation-that-doesnt-suck/
    ISO8601_REGEX = /^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/

    attr_reader :target, :updated, :priority, :changefreq, :validate_time

    def initialize(target, opts={})
      @target         = target.to_s.strip
      @updated        = opts[:updated]  || Time.now
      @priority       = opts[:priority] || DEFAULT_PRIORITY
      @changefreq     = opts[:period]   || :weekly
      @validate_time  = (opts[:validate_time] != false)
      
      unless @updated.kind_of?(Time) || @updated.kind_of?(Date) || @updated.kind_of?(String)
        raise ArgumentError, "Time, Date, or ISO8601 String required for :updated!"
      end

      if @validate_time && @updated.kind_of?(String) && !(@updated =~ ISO8601_REGEX)
        raise ArgumentError, "String provided to :updated did not match ISO8601 standard!"
      end
      
      unless XmlSitemap::PERIODS.include?(@changefreq)
        raise ArgumentError, "Invalid :period value '#{@changefreq}'"
      end

      @updated = @updated.to_time if @updated.kind_of?(Date)
    end

    # Returns the timestamp value for rendere
    #
    def lastmod_value
      if @updated.kind_of?(Time)
        @updated.utc.iso8601
      else
        @updated.to_s
      end
    end
  end
end