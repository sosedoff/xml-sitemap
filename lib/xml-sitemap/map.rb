module XmlSitemap
  class Item
    attr_reader :target, :updated, :priority, :changefreq
    
    def initialize(target, opts={})
      @target     = target.to_s.strip
      @updated    = opts[:updated]  || Time.now
      @priority   = opts[:priority] || 0.5
      @changefreq = opts[:period]   || :weekly
      
      # allow only date or time object
      unless @updated.kind_of?(Time) || @updated.kind_of?(Date)
        raise ArgumentError, "Time or Date required for :updated!"
      end
      
      # use full time and date only!
      @updated = @updated.to_time if @updated.kind_of?(Date)
      
      # use UTC only!
      @updated = @updated.utc
    end
  end

  class Map
    attr_reader   :domain, :items
    attr_reader   :buffer
    attr_reader   :created_at
    attr_reader   :root
    
    # Creates new Map class for specified domain
    def initialize(domain, opts={})
      @domain     = domain.to_s.strip
      raise ArgumentError, 'Domain required!' if @domain.empty?
      
      @created_at = opts[:time]   || Time.now.utc
      @secure     = opts[:secure] || false
      @home       = opts.key?(:home) ? opts[:home] : true
      @root       = opts.key?(:root) ? opts[:root] : true
      @items      = []
      
      self.add('/', :priority => 1.0) if @home === true
      
      yield self if block_given?
    end
    
    # Yields Map class for easier access
    def generate
      raise ArgumentError, 'Block required' unless block_given?
      yield self
    end
    
    # Add new item to sitemap list
    def add(target, opts={})
      raise RuntimeError, 'Only less than 50k records allowed!' if @items.size >= 50000
      raise ArgumentError, 'Target required!' if target.nil?
      raise ArgumentError, 'Target is empty!' if target.to_s.strip.empty?
      
      opts[:updated] = @created_at unless opts.key?(:updated)
      item = XmlSitemap::Item.new(process_target(target), opts)
      @items << item
      item
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
    
    # Get full url for index
    def index_url(offset)
      "http://#{@domain}/sitemap-#{offset}.xml"
    end
    
    # Render XML
    def render
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!(:xml, :version => '1.0', :encoding => 'UTF-8')
      xml.urlset(XmlSitemap::MAP_SCHEMA_OPTIONS) { |s|
        @items.each do |item|
          s.url do |u|
            u.loc        item.target
            u.lastmod    item.updated.utc.iso8601
            u.changefreq item.changefreq.to_s
            u.priority   item.priority.to_s
          end
        end
      }.to_s
    end
    
    # Render XML sitemap into the file
    def render_to(path, opts={})
      overwrite = opts[:overwrite] || true
      path = File.expand_path(path)
      
      if File.exists?(path) && !overwrite
        raise RuntimeError, "File already exists and not overwritable!"
      end
      
      File.open(path, 'w') { |f| f.write(self.render) }
    end
    
    protected
  
    # Process target path or url
    def process_target(str)
      if @root == true
        url(str =~ /^\// ? str : "/#{str}")
      else
        str =~ /^(http|https)/i ? str : url(str =~ /^\// ? str : "/#{str}")
      end
    end
  end
end
