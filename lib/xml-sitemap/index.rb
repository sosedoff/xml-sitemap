module XmlSitemap
  class Index
    attr_reader :maps

    # Initialize a new Index instance
    #
    # opts   - Index options
    #
    # opts[:secure] - Force HTTPS for all items. (default: false)
    #
    def initialize(opts={})
      @maps     = []
      @offsets  = Hash.new(0)
      @secure   = opts[:secure] || false

      yield self if block_given?
    end

    # Add map object to index
    #
    # map - XmlSitemap::Map instance
    #
    def add(map, use_offsets=true, start_offset = 0)
      raise ArgumentError, 'XmlSitemap::Map object required!' unless map.kind_of?(XmlSitemap::Map)
      raise ArgumentError, 'Map is empty!' if map.empty?

      @maps << {
        :loc     => use_offsets ? map.index_url(start_offset + @offsets[map.group], @secure) : map.plain_index_url(@secure),
        :lastmod => map.created_at.utc.iso8601
      }
      @offsets[map.group] += 1
    end

    # Generate sitemap XML index
    #
    def render
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
      xml.sitemapindex(XmlSitemap::INDEX_SCHEMA_OPTIONS) { |s|
        @maps.each do |item|
          s.sitemap do |m|
            m.loc        item[:loc]
            m.lastmod    item[:lastmod]
          end
        end
      }.to_s
    end

    # Render XML sitemap index into the file
    #
    # path    - Output filename
    # options - Options hash
    #
    # options[:ovewrite] - Overwrite file contents (default: true)
    #
    def render_to(path, options={})
      overwrite = options[:overwrite] || true
      path = File.expand_path(path)

      if File.exists?(path) && !overwrite
        raise RuntimeError, "File already exists and not overwritable!"
      end

      File.open(path, 'w') { |f| f.write(self.render) }
    end
  end
end
