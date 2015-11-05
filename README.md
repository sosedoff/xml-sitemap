# XmlSitemap [![Build Status](https://secure.travis-ci.org/sosedoff/xml-sitemap.png?branch=master)](http://travis-ci.org/sosedoff/xml-sitemap) [![Dependency Status](https://www.versioneye.com/ruby/xml-sitemap/badge.svg)](https://www.versioneye.com/ruby/xml-sitemap)

XmlSitemap is a ruby library that provides an easy way to generate XML sitemaps and indexes.

It does not have any web-framework dependencies and could be used in any ruby-based application.

## Installation

Install via rubygems:

```
gem install xml-sitemap
```

Or using latest source code:

```
rake install
```
  
## Configuration

Add gem to your Gemfile and you're ready to go:

```ruby
gem 'xml-sitemap'
```

## Usage
  
Simple usage:

```ruby
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
```

Render map output:

```ruby
# Render the sitemap XML
map.render

# Render and save XML to the output file
map.render_to('/path/to/file.xml')

# You can also use compression
map.render_to('/path/to/file.xml.gz', :gzip => true)

# If you didnt specify .gz extension to the filename,
# XmlSitemap will automatically append it
# => content will be saved to /path/to/file.xml.gz
map.render_to('/path/to/file.xml', :gzip => true)
```

You can also create a map via shortcut:

```ruby
map = XmlSitemap.new('foobar.com')
map = XmlSitemap.map('foobar.com')
```
  
By default XmlSitemap creates a map with link to homepage of your domain. 

Homepage priority is `1.0`.

List of available update periods:

- `:none`
- `:always`
- `:hourly`
- `:daily`
- `:weekly`
- `:monthly`
- `:yearly`
- `:never`

### Generating Maps

When creating a new map object, you can specify a set of options.

```ruby
map = XmlSitemap::Map.new('mydomain.com', options)
```

Available options:

- `:secure` - Will add all sitemap items with https prefix. *(default: false)*
- `:home`   - Disable homepage autocreation, but you still can do that manually. *(default: true)*
- `:root`   - Force all links to fall under the main domain. You can add full urls (not paths) if set to false. *(default: true)*
- `:time`   - Provide a creation time for the sitemap. (default: current time)
- `:group`  - Group name for sitemap index. *(default: sitemap)* 

### Render Engines

XmlSitemap has a few different rendering engines. You can select one passing argument to `render` method. 

Available engines:

- `:string` - Uses plain strings (for performance). Default.
- `:builder` - Uses Builder::XmlMarkup.
- `:nokogiri` - Uses Nokogiri library. Requires `nokogiri` gem.

### Sitemap Indexes

Regular sitemap does not support more than 50k records, so if you're generating a huge sitemap you need to use XmlSitemap::Index.

Index is just a collection of links to all the website's sitemaps.

Usage:

```ruby
map = XmlSitemap::Map.new('domain.com')
map.add 'page'
    
index = XmlSitemap::Index.new

# or if you want the URLs to use HTTPS
index = XmlSitemap::Index.new(:secure => true)

# or via shortcut
index = XmlSitemap.index

# Add a map to the index
index.add(map)

# Render as XML
index.render

# Render XML to the output file
index.render_to('/path/to/file.xml')
```

## Testing

To execute test suite run:

```
bundle exec rake test
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Copyright (c) 2010-2013 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
