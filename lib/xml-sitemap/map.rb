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
      
      @updated = @updated.to_time if @updated.kind_of?(Date)
    end
    
    def lastmod_value
      if (@updated.is_a? Time)
        @updated.utc.iso8601
      else
        @updated.to_s
      end
    end
    
  end
  
  class Map
    attr_reader   :domain, :items
    attr_reader   :buffer
    attr_reader   :created_at
    attr_reader   :root
    attr_reader   :group
    
    # Creates new Map class for specified domain
    def initialize(domain, opts={})
      @domain     = domain.to_s.strip
      raise ArgumentError, 'Domain required!' if @domain.empty?
      
      @created_at = opts[:time]   || Time.now.utc
      @secure     = opts[:secure] || false
      @home       = opts.key?(:home) ? opts[:home] : true
      @root       = opts.key?(:root) ? opts[:root] : true
      @group      = opts[:group] || "sitemap"
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
      raise RuntimeError, 'Only up to 50k records allowed!' if @items.size > 50000
      raise ArgumentError, 'Target required!' if target.nil?
      raise ArgumentError, 'Target is empty!' if target.to_s.strip.empty?
      
      url = process_target(target)
      
      if url.length > 2048
        raise ArgumentError, "Target can't be longer than 2,048 characters!"
      end
      
      opts[:updated] = @created_at unless opts.key?(:updated)
      item = XmlSitemap::Item.new(url, opts)
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
      "http://#{@domain}/#{@group}-#{offset}.xml"
    end
    
    # Render XML
    def render(method = :string)
      case method
      when :nokogiri
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
      when :builder
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
      else # :string is default
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
    
    # Render XML sitemap into the file
    def render_to(path, options={})
      overwrite = options[:overwrite] == true || true
      compress  = options[:gzip]      == true || false
      
      path = File.expand_path(path)
      path << ".gz" unless path =~ /\.gz\z/i if compress
      
      if File.exists?(path) && !overwrite
        raise RuntimeError, "File already exists and not overwritable!"
      end
      
      File.open(path, 'w') do |f|
        unless compress
          f.write(self.render)
        else
          gz = Zlib::GzipWriter.new(f)
          gz.write(self.render)
          gz.close
        end
      end
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
