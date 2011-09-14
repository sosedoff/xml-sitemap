module XmlSitemap  
  class Map
    attr_reader   :domain, :items
    attr_reader   :buffer
    attr_reader   :created_at
    attr_reader   :root
    attr_reader   :group
    
    # Initializa a new Map instance
    #
    # domain - Primary domain for the map (required)
    # opts   - Map options
    #
    # opts[:home]   - Automatic homepage creation. To disable set to false. (default: true)
    # opts[:secure] - Force HTTPS for all items. (default: false)
    # opts[:time]   - Set default lastmod timestamp for items (default: current time)
    # opts[:group]  - Group name for sitemap index. (default: sitemap)
    # opts[:root]   - Force all links to fall under the main domain.
    #                 You can add full urls (not paths) if set to false. (default: true)
    #
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
    
    # Adds a new item to the map
    #
    # target - Path or url
    # opts   - Item options
    #
    # opts[:updated]       - Lastmod property of the item
    # opts[:period]        - Update frequency. (default - :weekly)
    # opts[:priority]      - Item priority. (default: 0.5)
    # opts[:validate_time] - Skip time validation if want to insert raw strings.
    # 
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
    #
    def size
      @items.size
    end
    
    # Returns true if sitemap does not have any items
    #
    def empty?
      @items.empty?
    end
    
    # Generate full url for path
    #
    def url(path='')
      "#{@secure ? 'https' : 'http'}://#{@domain}#{path}"
    end
    
    # Get full url for index
    #
    def index_url(offset)
      "http://#{@domain}/#{@group}-#{offset}.xml"
    end
    
    # Render XML
    #
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
    #
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
    #
    def process_target(str)
      if @root == true
        url(str =~ /^\// ? str : "/#{str}")
      else
        str =~ /^(http|https)/i ? str : url(str =~ /^\// ? str : "/#{str}")
      end
    end
  end
end
