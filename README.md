XmlSitemap
==========

XmlSitemap is a Ruby library that provides an easy way to generate XML sitemaps and indexes.

It does not have any web-framework dependencies thus might be used almost anywhere.

## Installing XmlSitemap

    $ gem install xml-sitemap
  
## Sample usage

In your Gemfile:

    gem 'xml-sitemap'
  
Simple map usage:

    map = XmlSitemap::Map.new('domain.com') do |m|
      # Adds a simple page
      m.add '/page1'  
      
      # You can drop leading slash, it will be automatically added
      m.add 'page2'
      
      # Set the page priority
      m.add 'page3', :priority => 0.2
      
      # Specify last modification date and update frequiency
      m.add 'page4', :updated => Date.today, :period => :never
    end
    
    map.render                           # => render to XML
    map.render_to('/path/to/file.xml')   # => render into a file
  
By default XmlSitemap creates a map with link to homepage of your domain. It's a priority 1.0. Default priority is 0.5.

List of periods:

- :none,
- :always
- :hourly
- :daily
- :weekly
- :monthly
- :yearly
- :never

## XmlSitemap::Map

When creating a new map object, you can specify a set of options.

    map = XmlSitemap::Map.new('mydomain.com', options)

Available options:

- :secure - Will add all sitemap items with https prefix. (default: false)
- :home   - Disable homepage autocreation, but you still can do that manually. (default: true)
- :root   - Force all links to fall under the main domain. You can add full urls (not paths) if set to false. (default: true)
- :time   - Provide a creation time for the sitemap. (default: current time)

## XmlSitemap::Index

Regular sitemap does not support more than 50k records, so if you generation a huge sitemap you need to use XmlSitemap::Index.
Index is just a collection of links to all the website's sitemaps.

Usage:

    map = XmlSitemap::Map.new('domain.com')
    map.add 'page'
    
    index = XmlSitemap::Index.new
    index.add map
    
    index.render                          # => render index to XML
    index.render_to('/path/to/file.xml')  # => render into a file
    
## TODO

- Gzip sitemaps and index file

## License

Copyright &copy; 2010 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.