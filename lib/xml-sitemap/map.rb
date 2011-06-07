module XmlSitemap
  class Item
    attr_reader :path
    attr_reader :updated
    attr_reader :priority
    attr_reader :changefreq
    
    def initialize(opts={})
      @path       = opts[:url] if opts.key?(:url)
      @updated    = opts[:updated]  || Time.now.utc
      @priority   = opts[:priority] || 0.5
      @changefreq = opts[:period]   || :weekly
    end
  end

  class Map
    attr_reader   :domain, :items
    attr_reader   :buffer
    attr_reader   :created_at
    attr_accessor :index_path
    
    # Creates new Map class for specified domain
    def initialize(domain, opts={})
      @domain     = domain
      @created_at = opts[:time]       || Time.now.utc
      @secure     = opts[:secure]     || false
      @items      = []
      
      self.add(:url => '/', :priority => 1.0)
      
      yield self if block_given?
    end
    
    # Yields Map class for easier access
    def generate
      raise ArgumentError, 'Block required' unless block_given?
      yield self
    end
    
    # Add new item to sitemap list
    def add(opts)
      opts[:updated] = @created_at unless opts.key?(:updated)
      @items << XmlSitemap::Item.new(opts)
    end
    
    # Get map items count
    def size
      @items.size
    end
    
    # Returns true if sitemap does not have any items
    def empty?
      @items.empty?
    end
    
    # Generate full url for path
    def url(path='')
      "#{@secure ? 'https' : 'http'}://#{@domain}#{path}"
    end
    
    # Render XML
    def render
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
      xml.urlset(XmlSitemap::MAP_SCHEMA_OPTIONS) { |s|
        @items.each do |item|
          s.url do |u|
            u.loc        url(item.path)
            u.lastmod    item.updated.utc.iso8601
            u.changefreq item.changefreq.to_s
            u.priority   item.priority.to_s
          end
        end
      }.to_s
    end
    
    alias :to_s :render
  end
end
